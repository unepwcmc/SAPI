class AddInternalNoteToInputsAndOutputs < ActiveRecord::Migration[4.2]
  def change
    add_column :nomenclature_change_outputs, :internal_note, :text
    add_column :nomenclature_change_inputs, :internal_note, :text
  end
end
