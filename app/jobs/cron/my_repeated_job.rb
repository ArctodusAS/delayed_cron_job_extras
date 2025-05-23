require_relative '../application_job.rb'

class MyRepeatedJob < ApplicationJob
  CRON =  '0 11 * * *'

  queue_as :low_priority

  def perform
  end
end
