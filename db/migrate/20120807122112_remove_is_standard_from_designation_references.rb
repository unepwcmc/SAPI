class RemoveIsStandardFromDesignationReferences < ActiveRecord::Migration
  def change
    remove_column :designation_references, :is_standard
  end
end
