require 'bundler/setup'
Bundler.setup

require 'active_job'
require 'delayed_job_active_record'
require 'delayed_cron_job'
require 'delayed_cron_job_extras'

require_relative '../app/jobs/cron/my_repeated_job.rb'

Delayed::Worker.logger = Logger.new("/tmp/dj.log")
ENV["RAILS_ENV"] = "test"

config = YAML.load(File.read("spec/database.yml"))
ActiveRecord::Base.establish_connection config['sqlite3']
ActiveRecord::Base.logger = Delayed::Worker.logger
ActiveRecord::Migration.verbose = false

migration_template = File.open("spec/migration.rb")
# need to eval the template with the migration_version intact
migration_context =
  Class.new do
    def my_binding
      binding
    end

    private

    def migration_version
      "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]" if ActiveRecord::VERSION::MAJOR >= 5
    end
  end
migration_ruby = ERB.new(migration_template.read).result(migration_context.new.my_binding)
eval(migration_ruby) # rubocop:disable Security/Eval

ActiveRecord::Schema.define do
  if table_exists?(:delayed_jobs)
    # `if_exists: true` was only added in Rails 5
    drop_table :delayed_jobs
  end

  CreateDelayedJobs.up

  create_table :stories, primary_key: :story_id, force: true do |table|
    table.string :text
    table.boolean :scoped, default: true
  end
end

RSpec.configure do |config|
end
