require_relative '../application_job.rb'

class PrefixedMyRepeatedJob < ApplicationJob
  queue_as :low_priority

  def self.cron
    '0 11 * * *'
  end

  def perform; end
end
