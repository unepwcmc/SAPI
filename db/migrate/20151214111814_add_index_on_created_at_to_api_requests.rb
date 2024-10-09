class AddIndexOnCreatedAtToApiRequests < ActiveRecord::Migration[4.2]
  def change
    add_index :api_requests, [ :created_at ]
  end
end
