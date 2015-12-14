class AddIndexOnCreatedAtToApiRequests < ActiveRecord::Migration
  def change
    add_index :api_requests, [:created_at]
  end
end
