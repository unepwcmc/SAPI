class AddIndexOnLastDownloadAtToDocumentsBulkDownloads < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :documents_bulk_downloads, :last_download_at, algorithm: :concurrently
  end
end
