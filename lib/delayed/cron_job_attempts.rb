# frozen_string_literal: true

module Delayed
  # Tracks consecutive failures using last_error, which DelayedCronJob clears before each run.
  module CronJobAttempts
    def schedule_next_run
      self.attempts = last_error.present? ? attempts + 1 : 0
      unlock
      set_next_run_at
      save!
    end
  end
end

Delayed::Backend::ActiveRecord::Job.prepend(Delayed::CronJobAttempts)
