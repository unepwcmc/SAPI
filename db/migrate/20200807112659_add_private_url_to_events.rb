class AddPrivateUrlToEvents < ActiveRecord::Migration
  def change
    add_column :events, :private_url, :text
  end
end
