class CreateNomenclatureChangeReassignmentTargets < ActiveRecord::Migration
  def change
    create_table :nomenclature_change_reassignment_targets do |t|
      t.integer :nomenclature_change_reassignment_id
      t.integer :nomenclature_change_output_id
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
  end
end
