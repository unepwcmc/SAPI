class AddIsPrimaryOutputToOutputs < ActiveRecord::Migration
  def change
    add_column :nomenclature_change_outputs, :is_primary_output, :boolean, :default => true
  end
end
