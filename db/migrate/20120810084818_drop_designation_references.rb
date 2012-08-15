class DropDesignationReferences < ActiveRecord::Migration
  def change
    drop_table :designation_references
  end
end
