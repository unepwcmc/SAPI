module SapiModule
  module RetryableOnDeadlock
    def retry_on_deadlock(retry_count = 0, max_retries = 5, retry_delay = 30, &block)
      block.call
    rescue ActiveRecord::LockWaitTimeout => e
      if retry_count < max_retries
        Rails.logger.debug [
          "Deadlock detected on attempt #{retry_count + 1} of #{max_retries}:",
          e,
          "Retrying in #{retry_delay} seconds"
        ].join("\n\n")

        sleep retry_delay

        return retry_on_deadlock(
          retry_count + 1, max_retries, retry_delay, &block
        )
      end

      Rails.logger.debug [
        "Deadlock detected on attempt #{retry_count + 1} of #{max_retries}:",
        e,
        'No more retries.'
      ].join("\n\n")

      raise e
    end
  end

  def self.rebuild
    SapiModule::StoredProcedures.rebuild
  end

  def self.database_summary
    SapiModule::Summary.database_summary
  end
end
