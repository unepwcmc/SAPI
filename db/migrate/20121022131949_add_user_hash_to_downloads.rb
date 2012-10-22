class AddUserHashToDownloads < ActiveRecord::Migration
  def change
    add_column :downloads, :user_id, :string
  end
end
