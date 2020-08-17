# Delayed cron job exras

## Track running time and memory usage:  

initializers/delayed_job.rb:
```
Delayed::Worker.plugins << Delayed::Plugins::JobTracker
```

Migration:  
```
add_column :delayed_jobs, :last_run_took, :float
add_column :delayed_jobs, :last_run_mem_mb, :float
```


## Keep jobs in sync:  

Put the cron jobs in app/jobs/cron/  

```
desc "Setup delayed job cron tasks"
task :cron_setup => :environment do
  puts "Updating delayed cron job "
  Delayed::JobMaintainer.update_jobs
end

Capistrano example:  
```
after "delayed_job:restart", "deploy:cron_setup"
```

Priority must be specified:  
```
Delayed::Worker.queue_attributes = {
  default: { priority: 0 },
  low_priority: { priority: 10 }
}
```
Set cron config automatically when a job is enqueued:  

```
class ApplicationJob < ActiveJob::Base
  def self.cron; end

  before_enqueue do |job|
    job.cron = self.class.cron
  end
end
```
