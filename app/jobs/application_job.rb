class ApplicationJob < ActiveJob::Base
  CRON = nil
  self.queue_adapter = :delayed_job

  before_enqueue do |job|
    job.cron = self.class::CRON
  end
end
