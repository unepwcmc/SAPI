class CreateDownloadZips < ActiveRecord::Migration[7.1]
  def change
    create_table :download_zips do |t|
      t.string :checksum, null: false
      t.jsonb :document_ids, null: false, default: []
      t.string :status, null: false, default: 'pending'
      t.text :error_message
      t.timestamp :processing_at
      t.timestamp :completed_at

      t.timestamps
    end

    # The checksum is the content-addressed identity of a generated ZIP. It
    # must stay unique so identical document selections can converge on one
    # reusable artifact instead of racing to create duplicates.
    add_index :download_zips, :checksum, unique: true
    add_index :download_zips, :status
  end
end
