##
# When a user logs into the S+ API site, they have a long wait because the
# user page does a seq scan of all requests ever to show the user stats on their
# requests. Similarly it takes a while to navigate around the API usage pages
# in the S+ admin area. These indexes address this.

class AddApiAuditPerformanceIndexes < ActiveRecord::Migration[7.1]
  # These indexes are for a large table which gets frequent writes and which
  # we do not want to lock. Therefore run concurrently, which requires not being
  # inside a transaction. We also use `IF NOT EXISTS` because in the event this
  # change fails, it does not roll back and it is safer to redo/undo that way

  disable_ddl_transaction!

  def change
    add_index :api_requests, [
      :user_id, :created_at, :response_status
    ], algorithm: :concurrently, if_not_exists: true

    add_index :api_requests, [
      :user_id, :response_status, :created_at
    ], algorithm: :concurrently, if_not_exists: true

    add_index :api_requests, [
      :response_status, :created_at
    ], algorithm: :concurrently, if_not_exists: true

    # strong migrations objects to four columns but this is fine, because it is
    # a big table and the first three have low cardinality
    safety_assured do
      add_index :api_requests, [
        :controller, :action, :response_status, :created_at
      ], algorithm: :concurrently, if_not_exists: true
    end
  end
end
