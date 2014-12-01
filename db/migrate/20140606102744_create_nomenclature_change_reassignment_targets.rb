class CreateNomenclatureChangeReassignmentTargets < ActiveRecord::Migration
  def change
    create_table :nomenclature_change_reassignment_targets do |t|
      t.integer :nomenclature_change_reassignment_id, :null => false
      t.integer :nomenclature_change_output_id, :null => false
      t.integer :created_by_id, :null => false
      t.integer :updated_by_id, :null => false

      t.timestamps
    end
    add_foreign_key 'nomenclature_change_reassignment_targets', 'users',
      name: 'nomenclature_change_reassignment_targets_created_by_id_fk',
      column: 'created_by_id'
    add_foreign_key 'nomenclature_change_reassignment_targets', 'users',
      name: 'nomenclature_change_reassignment_targets_updated_by_id_fk',
      column: 'updated_by_id'
    add_foreign_key 'nomenclature_change_reassignment_targets', 'nomenclature_change_reassignments',
      name: 'nomenclature_change_reassignment_targets_reassignment_id_fk',
      column: 'nomenclature_change_reassignment_id'
    add_foreign_key 'nomenclature_change_reassignment_targets', 'nomenclature_change_outputs',
      name: 'nomenclature_change_reassignment_targets_output_id_fk',
      column: 'nomenclature_change_output_id'
  end
end
