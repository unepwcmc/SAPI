class AddDisplayNameToDownloads < ActiveRecord::Migration
  def change
    add_column :downloads, :display_name, :string
  end
end
