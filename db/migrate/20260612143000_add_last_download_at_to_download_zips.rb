class AddLastDownloadAtToDownloadZips < ActiveRecord::Migration[8.1]
  def change
    add_column :download_zips, :last_download_at, :datetime
  end
end
