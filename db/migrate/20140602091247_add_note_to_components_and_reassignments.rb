class AddNoteToComponentsAndReassignments < ActiveRecord::Migration
  def change
    add_column :nomenclature_change_components, :note, :text
    add_column :nomenclature_change_reassignments, :note, :text
  end
end
