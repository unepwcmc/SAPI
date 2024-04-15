class AddIsPrimaryOutputToOutputs < ActiveRecord::Migration[4.2]
  def change
    add_column :nomenclature_change_outputs, :is_primary_output, :boolean, :default => true
  end
end
