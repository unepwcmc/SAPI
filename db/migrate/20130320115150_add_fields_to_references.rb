class AddFieldsToReferences < ActiveRecord::Migration
  def change
    change_table :references do |t|
      t.text :citation
      t.text :publisher
    end
  end
end
