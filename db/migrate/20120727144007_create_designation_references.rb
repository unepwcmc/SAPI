class CreateDesignationReferences < ActiveRecord::Migration
  def up
    create_table :designation_references, :force => true do |t|
      t.integer  :designation_id, :null => false
      t.integer  :reference_id, :null => false
      t.boolean  :is_standard, :null => false, :default => false
    end
    add_foreign_key :designation_references, :designations, :name => :designation_references_designation_id_fk
    add_foreign_key :designation_references, :references, :name => :designation_references_reference_id_fk
  end

  def down
    drop_table :designation_references
  end
end
