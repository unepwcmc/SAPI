class ApplicationJob < ActiveJob::Base
  # Some jobs are long-running, others are triggered frequently.
  # Long-running jobs which fail should not be retried every few hours.
  # Default to not retrying. Jobs that are safe to retry can override this.
  sidekiq_options retry: false
end
