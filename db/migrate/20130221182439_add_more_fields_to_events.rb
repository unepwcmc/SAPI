class AddMoreFieldsToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.column :effective_at, :datetime
      t.column :published_at, :datetime
      t.column :description, :text
      t.column :url, :text
    end
  end
end
