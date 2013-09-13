class RemoveNotNullConstraintFromReferences < ActiveRecord::Migration
  def up
    change_column :references, :title, :text, :null => true
    change_column :references, :citation, :text, :null => false
  end

  def down
    change_column :references, :title, :text, :null => false
    change_column :references, :citation, :text, :null => true
  end
end
