class AddMultiLingualNotesToNomenclatureChanges < ActiveRecord::Migration
  def change
    rename_column :nomenclature_change_inputs, :note, :note_en
    add_column :nomenclature_change_inputs, :note_es, :text
    add_column :nomenclature_change_inputs, :note_fr, :text
    rename_column :nomenclature_change_outputs, :note, :note_en
    add_column :nomenclature_change_outputs, :note_es, :text
    add_column :nomenclature_change_outputs, :note_fr, :text
    rename_column :nomenclature_change_reassignments, :note, :note_en
    add_column :nomenclature_change_reassignments, :note_es, :text
    add_column :nomenclature_change_reassignments, :note_fr, :text
    add_column :nomenclature_change_reassignments, :internal_note, :text
  end
end
