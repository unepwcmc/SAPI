class AddIndexOnLastDownloadAtToDownloadZips < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :download_zips, :last_download_at, algorithm: :concurrently
  end
end
