##
# When a user logs into the S+ API site, they have a long wait because the
# user page does a seq scan of all requests ever to show the user stats on their
# requests. This index addresses this.

class AddApiAuditPerformanceIndexes < ActiveRecord::Migration[7.1]
  # This index are for a large table which gets frequent writes and which
  # we do not want to lock. Therefore run concurrently, which requires not being
  # inside a transaction. We also use `IF NOT EXISTS` because in the event this
  # change fails, it does not roll back and it is safer to redo/undo that way

  disable_ddl_transaction!

  def change
    add_index :api_requests, [
      :user_id, :response_status, :created_at
    ], algorithm: :concurrently, if_not_exists: true
  end
end
