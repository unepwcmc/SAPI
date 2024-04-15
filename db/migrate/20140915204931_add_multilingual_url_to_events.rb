class AddMultilingualUrlToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :multilingual_url, :text
  end
end
