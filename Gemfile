source "http://rubygems.org"
ruby File.read(".ruby-version").strip

group :test, :development do
  gem 'rspec', '~> 3.9'
  gem 'activejob', '8.0.2'
  gem 'delayed_job_active_record', '~> 4.1'
  gem 'delayed_cron_job', '~> 0.7'
  gem "delayed_cron_job_extras", :path => '.'
  gem "sqlite3"
end
