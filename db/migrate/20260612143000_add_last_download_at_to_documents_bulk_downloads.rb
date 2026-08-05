class AddLastDownloadAtToDocumentsBulkDownloads < ActiveRecord::Migration[8.1]
  def change
    add_column :documents_bulk_downloads, :last_download_at, :datetime
  end
end
