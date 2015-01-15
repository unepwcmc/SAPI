class CreateApiRequests < ActiveRecord::Migration
  def change
    create_table :api_requests do |t|
      t.references :user, index: true
      t.string :controller
      t.string :action
      t.string :format
      t.text :params
      t.string :ip
      t.integer :response_status
      t.text :error_message

      t.timestamps
    end
  end
end
