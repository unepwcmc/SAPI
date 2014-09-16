class AddMultilingualUrlToEvents < ActiveRecord::Migration
  def change
    add_column :events, :multilingual_url, :text
  end
end
