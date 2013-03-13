class AddDesignationIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :designation_id, :integer
    add_foreign_key :events, :designations, :name => :events_designation_id_fk
  end
end
