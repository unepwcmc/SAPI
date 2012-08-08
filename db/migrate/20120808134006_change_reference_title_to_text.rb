class ChangeReferenceTitleToText < ActiveRecord::Migration
  def change
    change_column :references, :title, :text
  end
end
