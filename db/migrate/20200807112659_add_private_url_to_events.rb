class AddPrivateUrlToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :private_url, :text
  end
end
