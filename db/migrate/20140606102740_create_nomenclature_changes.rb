class CreateNomenclatureChanges < ActiveRecord::Migration
  def change
    create_table :nomenclature_changes do |t|
      t.integer :event_id
      t.string :type, :null => false
      t.string :status, :null => false
      t.integer :created_by_id, :null => false
      t.integer :updated_by_id, :null => false

      t.timestamps
    end
    add_foreign_key 'nomenclature_changes', 'users',
      name: 'nomenclature_changes_created_by_id_fk',
      column: 'created_by_id'
    add_foreign_key 'nomenclature_changes', 'users',
      name: 'nomenclature_changes_updated_by_id_fk',
      column: 'updated_by_id'
    add_foreign_key 'nomenclature_changes', 'events',
      name: 'nomenclature_changes_event_id_fk',
      column: 'event_id'
  end
end
