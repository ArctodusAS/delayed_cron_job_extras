# frozen_string_literal: true

require 'spec_helper'
require 'active_support/testing/time_helpers'

class FailingAttemptsTestJob
  def perform
    raise 'Scheduled failure'
  end
end

describe 'Cron job attempts' do
  include ActiveSupport::Testing::TimeHelpers

  before { Delayed::Job.delete_all }
  after { Delayed::Job.delete_all }

  it 'should count consecutive failures without changing the cron schedule' do
    travel_to(Time.utc(2026, 1, 1, 12)) do
      job = Delayed::Job.enqueue(FailingAttemptsTestJob.new, cron: '*/15 * * * * UTC')
      worker = Delayed::Worker.new
      1.upto(5) do |failure_count|
        job.update!(run_at: Time.current)
        expect(worker.work_off(1)).to eq([0, 1])
        expect(job.reload.attempts).to eq(failure_count)
        expect(job.last_error.lines.first(2)).to eq(["RuntimeError\n", "Scheduled failure\n"])
        expect(job.run_at).to eq(Time.utc(2026, 1, 1, 12, 15))
        expect(job.locked_at).to be_nil
        expect(job.locked_by).to be_nil
      end
    end
  end

  it 'should reset attempts after a successful run' do
    MyRepeatedJob.perform_later
    job = Delayed::Job.first
    job.update!(attempts: 5, last_error: 'Previous failure', run_at: 1.minute.ago)
    worker = Delayed::Worker.new
    expect { worker.work_off(1) }.to change {
      job.reload.attempts
    }.from(5).to(0).and change {
      job.last_error
    }.from('Previous failure').to(nil)
  end

  it 'should leave retry behavior unchanged for non-cron jobs' do
    travel_to(Time.utc(2026, 1, 1, 12)) do
      job = Delayed::Job.enqueue(FailingAttemptsTestJob.new)
      worker = Delayed::Worker.new
      expect(worker.work_off(1)).to eq([0, 1])
      expect(job.reload.attempts).to eq(1)
      expect(job.run_at).to eq(Time.utc(2026, 1, 1, 12, 0, 6))
    end
  end
end
