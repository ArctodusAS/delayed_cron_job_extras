# List of hooks
# https://github.com/collectiveidea/delayed_job/blob/master/lib/delayed/lifecycle.rb
#
# Example
# https://github.com/collectiveidea/delayed_job/blob/master/lib/delayed/plugins/clear_locks.rb

module Delayed
  module Plugins
    class JobTracker < Plugin
      callbacks do |lifecycle|
        lifecycle.before(:perform) do |worker, job|
          @job_started = Time.now
        end
        lifecycle.after(:perform) do |worker, job|
          if job.cron.present?
            job_took = Time.now - @job_started
            memory_sampler = Delayed::MemorySampler.new
            memory_mb = memory_sampler.linux? ? memory_sampler.get_memory : -1
            # DelayedCronJob has already created a new DB job with the same attributes
            stored_job = Delayed::Job.find(job.id)
            stored_job.update!(last_run_took: job_took, last_run_mem_mb: memory_mb)
            GC.start
          end
        end
      end
    end
  end
end
