class AddDisplayFlagsToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :display_in_index, :boolean, :null => false, :default => false
    add_column :annotations, :display_in_footnote, :boolean, :null => false, :default => false
  end
end
