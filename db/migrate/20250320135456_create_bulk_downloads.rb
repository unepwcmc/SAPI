class CreateBulkDownloads < ActiveRecord::Migration[7.1]
  def change
    create_table :bulk_downloads do |t|
      t.string :download_type, null: false
      t.string :format, null: false
      t.jsonb :filters, null: false
      t.boolean :is_public, default: false, null: false
      t.jsonb :error_message, null: true
      t.jsonb :success_message, null: true
      t.integer :requestor_id, null: true
      t.timestamp :started_at, null: true
      t.timestamp :completed_at, null: true
      t.timestamp :expires_at, null: true

      t.timestamps
    end

    add_index :bulk_downloads, [ :requestor_id, :id ]

    # the table is empty, so no need to do this in a separate transaction
    safety_assured do
      add_foreign_key :bulk_downloads, :users, name: :bulk_downloads_requestor_fk, column: :requestor_id
    end
  end
end
