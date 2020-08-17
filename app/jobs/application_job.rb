class ApplicationJob < ActiveJob::Base
  self.queue_adapter = :delayed_job

  def self.cron; end

  before_enqueue do |job|
    job.cron = self.class.cron
  end
end
