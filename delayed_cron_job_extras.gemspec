Gem::Specification.new do |s|
  s.name = 'delayed_cron_job_extras'
  s.version = "0.0.1"
  s.date = %q{2020-08-17}
  s.summary = 'delayed_cron_job extras'
  s.authors = 'Bjørn Trondsen'
  s.files = [
    '.gitignore',
    'Gemfile',
    'Gemfile.lock',
    'LICENCE',
    'README.markdown',
    'Rakefile',
    'VERSION',
    'app/jobs/application_job.rb',
    'app/jobs/cron/my_repeated_job.rb',
    'delayed_cron_job_extras.gemspec',
    'lib/delayed/job_maintainer.rb',
    'lib/delayed/memory_sampler.rb',
    'lib/delayed/plugins/job_tracker.rb',
    'lib/delayed_cron_job_extras.rb',
    'spec/database.yml',
    'spec/delayed/job_maintainer_spec.rb',
    'spec/migration.rb',
    'spec/plugins/job_tracker_spec.rb',
    'spec/spec_helper.rb',
  ]
  s.require_paths = ["lib"]
end
