class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.text     :title, null: false
      t.text     :filename, null: false
      t.date     :date, null: false
      t.string   :type, null: false
      t.boolean  :is_public, null: false, default: true
      t.integer  :event_id
      t.integer  :language_id
      t.integer  :legacy_id
      t.integer  :created_by_id
      t.integer  :updated_by_id
    end
    add_foreign_key :documents, :events, name: :documents_event_id_fk,
      column: :event_id
    add_foreign_key :documents, :languages, name: :documents_language_id_fk,
      column: :language_id
    add_foreign_key :documents, :users, name: :documents_created_by_id_fk,
      column: :created_by_id
    add_foreign_key :documents, :users, name: :documents_updated_by_id_fk,
      column: :updated_by_id
  end
end
