class AddDesignationIdToChangeTypes < ActiveRecord::Migration
  def change
    add_column :change_types, :designation_id, :integer, :null => false
    add_foreign_key :change_types, :designations, :name => :change_types_designation_id_fk
  end
end
