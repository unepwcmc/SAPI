class CreateBulkDownloads < ActiveRecord::Migration[7.1]
  def change
    create_table :bulk_downloads do |t|
      t.string :download_type, null: false
      t.string :format, null: false
      t.jsonb :filters, null: false, default: {}
      t.boolean :is_public, default: false, null: false
      t.jsonb :error_message, null: true
      t.jsonb :success_message, null: true
      t.references :requestor, null: true, foreign_key: { to_table: :users }
      t.timestamp :started_at, null: true
      t.timestamp :completed_at, null: true
      t.timestamp :expires_at, null: true

      t.timestamps
    end

    add_index :bulk_downloads, [ :requestor_id, :id ]
  end
end
