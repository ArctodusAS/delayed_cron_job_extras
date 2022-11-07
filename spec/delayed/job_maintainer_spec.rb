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
    def find_by_job_class(job_class)
      Delayed::Job.where("handler LIKE '%job_class: #{job_class}%'")
    end

    it "should schedule MyRepeatedJob" do
      expect { Delayed::JobMaintainer.update_jobs }.to change {
        find_by_job_class("MyRepeatedJob").count
      }.from(0).to(1)
    end

    it "should recreate the jobs in case the cron configuration changes" do
      Delayed::JobMaintainer.update_jobs
      find_by_job_class("MyRepeatedJob").first.update!(cron: '1 1 1 1 1')
      expect { Delayed::JobMaintainer.update_jobs }.to change {
        find_by_job_class("MyRepeatedJob").first.cron
      }.from('1 1 1 1 1').to('0 11 * * *')
    end

    it "should not schedule the same cron job more than once" do
      5.times { Delayed::JobMaintainer.update_jobs }
      expect(find_by_job_class("MyRepeatedJob").count).to eq(1)
    end

    it "should schedule the different job with different prefix but same name" do
      Delayed::JobMaintainer.update_jobs
      expect(find_by_job_class("MyRepeatedJob").count).to eq (1)
      expect(find_by_job_class("PrefixedMyRepeatedJob").count).to eq (1)
    end

    it "should update the queue and priority" do
      Delayed::JobMaintainer.update_jobs
      job = find_by_job_class("MyRepeatedJob").first
      job.update!(priority: 5, queue: 'default')
      expect { Delayed::JobMaintainer.update_jobs }.to change { job.reload.priority }.from(5).to(10).and change {
        job.reload.queue
      }.from('default').to('low_priority')
    end

    it "should delete jobs that no longer exist" do
      Delayed::JobMaintainer.update_jobs
      job = find_by_job_class("MyRepeatedJob").first
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
