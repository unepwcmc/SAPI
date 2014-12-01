class CreateNomenclatureChangeOutputReassignmentsTable < ActiveRecord::Migration
  def change
    create_table :nomenclature_change_output_reassignments do |t|
      t.integer  :nomenclature_change_output_id, :null => false
      t.string   :type, :null => false
      t.string   :reassignable_type
      t.integer  :reassignable_id
      t.text     :note_en
      t.integer  :created_by_id, :null => false
      t.integer  :updated_by_id, :null => false
      t.datetime :created_at, :null => false
      t.datetime :updated_at, :null => false
      t.text     :note_es
      t.text     :note_fr
      t.text     :internal_note

      t.timestamps
    end

  add_foreign_key :nomenclature_change_output_reassignments, :nomenclature_change_outputs, name: "nomenclature_change_output_reassignments_output_id_fk"
  add_foreign_key :nomenclature_change_output_reassignments, :users, name: "nomenclature_change_output_reassignments_created_by_id_fk", column: :created_by_id
  add_foreign_key :nomenclature_change_output_reassignments, :users, name: "nomenclature_change_output_reassignments_updated_by_id_fk", column: :updated_by_id
  end
end
