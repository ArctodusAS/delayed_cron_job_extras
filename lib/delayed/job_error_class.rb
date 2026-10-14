# frozen_string_literal: true

# TODO: Strictly speaking, this does not belong here but is the only shared gem. Convert the repo into e.g delayed-job-arctodus if we end up using it longterm.
#
# Adds the exception class to Delayed Job's stored failure details.
module Delayed::JobErrorClass # rubocop:disable Style/ClassAndModuleChildren
  def error=(error)
    super
    self.last_error = "#{error.class}\n#{last_error}" if respond_to?(:last_error=)
  end
end

Delayed::Backend::Base.prepend(Delayed::JobErrorClass)
