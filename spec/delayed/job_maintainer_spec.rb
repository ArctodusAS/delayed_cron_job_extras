require 'spec_helper'

class Rails
  def self.root
    File.dirname(__FILE__).sub('spec/delayed','')
  end
end

describe Delayed::JobMaintainer do
  before(:each) do
    Delayed::Worker.queue_attributes = {
      default: { priority: 0 },
      low_priority: { priority: 10 }
    }
  end

  describe '#update_jobs' do
    it "should schedule MyRepeatedJob" do
      expect { Delayed::JobMaintainer.update_jobs }.to change {
        Delayed::Job.where("handler LIKE '%MyRepeatedJob%'").count
      }.from(0).to(1)
    end

    it "should recreate the jobs in case the cron configuration changes" do
      Delayed::JobMaintainer.update_jobs
      Delayed::Job.where("handler LIKE '%MyRepeatedJob%'").first.update!(cron: '1 1 1 1 1')
      expect { Delayed::JobMaintainer.update_jobs }.to change {
        Delayed::Job.where("handler LIKE '%MyRepeatedJob%'").first.cron
      }.from('1 1 1 1 1').to('0 11 * * *')
    end

    it "should not schedule the same cron job more than once" do
      5.times { Delayed::JobMaintainer.update_jobs }
      expect(Delayed::Job.where("handler LIKE '%MyRepeatedJob%'").count).to eq(1)
    end

    it "should update the queue and priority" do
      Delayed::JobMaintainer.update_jobs
      job = Delayed::Job.where("handler LIKE '%MyRepeatedJob%'").first
      job.update!(priority: 5, queue: 'default')
      expect { Delayed::JobMaintainer.update_jobs }.to change { job.reload.priority }.from(5).to(10).and change {
        job.reload.queue
      }.from('default').to('low_priority')
    end

    it "should delete jobs that no longer exist" do
      Delayed::JobMaintainer.update_jobs
      job = Delayed::Job.where("handler LIKE '%MyRepeatedJob%'").first
      job.handler.sub!('MyRepeatedJob','DeletedJob')
      job.save!
      expect { Delayed::JobMaintainer.update_jobs }.to change { Delayed::Job.where("handler LIKE '%DeletedJob%'").count }.from(1).to(0)
    end

    it "should not schedule the jobs without cron configuration" do
      Delayed::JobMaintainer.update_jobs
      expect(Delayed::Job.where(cron: nil).count).to eq(0)
    end
  end
end
