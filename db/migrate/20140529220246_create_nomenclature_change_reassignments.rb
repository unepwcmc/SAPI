class CreateNomenclatureChangeReassignments < ActiveRecord::Migration
  def change
    create_table :nomenclature_change_reassignments do |t|
      t.integer :nomenclature_change_input_id
      t.integer :nomenclature_change_output_id
      t.string :type
      t.string :reassignable_type
      t.integer :reassignable_id
      t.boolean :is_copy

      t.timestamps
    end

    add_foreign_key "nomenclature_change_reassignments", "nomenclature_change_components",
      name: "nomenclature_change_reassignments_input_id_fk",
      column: "nomenclature_change_input_id"
    add_foreign_key "nomenclature_change_reassignments", "nomenclature_change_components",
      name: "nomenclature_change_reassignments_output_id_fk",
      column: "nomenclature_change_output_id"
  end
end
