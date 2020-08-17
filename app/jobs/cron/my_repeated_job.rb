require_relative '../application_job.rb'

class MyRepeatedJob < ApplicationJob
  queue_as :low_priority

  def self.cron
    '0 11 * * *'
  end

  def perform
  end
end
