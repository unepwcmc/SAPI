class CreateNomenclatureChanges < ActiveRecord::Migration
  def change
    create_table :nomenclature_changes do |t|
      t.integer :event_id
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
    add_foreign_key "nomenclature_changes", "users", name: "nomenclature_changes_created_by_id_fk", column: "created_by_id"
    add_foreign_key "nomenclature_changes", "users", name: "nomenclature_changes_updated_by_id_fk", column: "updated_by_id"
  end
end
