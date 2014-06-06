class CreateNomenclatureChangeReassignments < ActiveRecord::Migration
  def change
    create_table :nomenclature_change_reassignments do |t|
      t.integer :nomenclature_change_input_id, :null => false
      t.string :type, :null => false
      t.string :reassignable_type
      t.integer :reassignable_id
      t.text :note
      t.integer :created_by_id, :null => false
      t.integer :updated_by_id, :null => false

      t.timestamps
    end
    add_foreign_key 'nomenclature_change_reassignments', 'users',
      name: 'nomenclature_change_reassignments_created_by_id_fk',
      column: 'created_by_id'
    add_foreign_key 'nomenclature_change_reassignments', 'users',
      name: 'nomenclature_change_reassignments_updated_by_id_fk',
      column: 'updated_by_id'
    add_foreign_key 'nomenclature_change_reassignments', 'nomenclature_change_inputs',
      name: 'nomenclature_change_reassignments_input_id_fk',
      column: 'nomenclature_change_input_id'
  end
end
