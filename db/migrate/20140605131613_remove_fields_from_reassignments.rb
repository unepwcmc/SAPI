class RemoveFieldsFromReassignments < ActiveRecord::Migration
  def self.up
    remove_column :nomenclature_change_reassignments, :nomenclature_change_output_id
    remove_column :nomenclature_change_reassignments, :is_copy
  end
  def self.down
    add_column :nomenclature_change_reassignments, :nomenclature_change_output_id, :integer
    add_column :nomenclature_change_reassignments, :note, :text
    add_column :nomenclature_change_reassignments, :is_copy, :boolean
  end
end
