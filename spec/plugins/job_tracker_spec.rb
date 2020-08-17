require 'spec_helper'

describe Delayed::Plugins::JobTracker do
  it 'should track run time and memory' do
    Delayed::Job.destroy_all
    Delayed::Worker.plugins << Delayed::Plugins::JobTracker
    expect(Delayed::Job.count).to eq(0)
    MyRepeatedJob.perform_later
    expect(Delayed::Job.count).to eq(1)
    job = Delayed::Job.first
    worker = Delayed::Worker.new
    job.update!(run_at: 1.minute.ago)
    expect(Delayed::Job.count).to eq(1)
    worker.work_off
    expect(Delayed::Job.count).to eq(1)
    job.reload
    expect(job.attempts).to eq(1)
    expect(job.last_error).to be_blank
    expect(job.last_run_took > 0).to be_truthy
    expect(job.last_run_mem_mb > 10).to be_truthy
  end
end
