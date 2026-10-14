# frozen_string_literal: true

require 'delayed_job_active_record'
require 'delayed_cron_job_extras'

describe Delayed::Backend::Base do
  let(:job) do
    Class.new do
      include Delayed::Backend::Base
      attr_accessor :last_error
    end.new
  end

  it 'should store the exception class before the unchanged message and backtrace' do
    error_class = stub_const('ApiForbiddenError', Class.new(StandardError))
    error = error_class.new('Housing 22 GUI')
    error.set_backtrace(["app/services/tripletex/rest_client/session.rb:46:in 'get_new_session_token'"])
    job.error = error
    expected_error = "ApiForbiddenError\nHousing 22 GUI\n#{error.backtrace.first}"
    expect(job.last_error).to eq(expected_error)
    expect(job.error).to equal(error)
    expect(error.message).to eq('Housing 22 GUI')
  end

  it 'should include the class for other job failures too' do
    error = RuntimeError.new('Something went wrong')
    error.set_backtrace(['app/jobs/another_job.rb:10'])
    job.error = error
    expect(job.last_error).to eq("RuntimeError\nSomething went wrong\napp/jobs/another_job.rb:10")
  end
end
