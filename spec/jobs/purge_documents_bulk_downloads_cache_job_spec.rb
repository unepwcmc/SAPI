require 'spec_helper'

RSpec.describe PurgeDocumentsBulkDownloadsCacheJob do
  before(:each) do
    DocumentsBulkDownload.find_each do |documents_bulk_download|
      documents_bulk_download.zip_file.purge if documents_bulk_download.zip_file.attached?
    end
    DocumentsBulkDownload.delete_all
  end

  describe '#perform' do
    it 'removes old cached bulk downloads and keeps newer ones' do
      old_documents_bulk_download = DocumentsBulkDownload.create!(
        checksum: 'old-download-zip',
        document_ids: [ 14903 ]
      )
      old_documents_bulk_download.zip_file.attach(
        io: StringIO.new('old zip'),
        filename: 'old-elibrary-documents.zip',
        content_type: 'application/zip'
      )
      old_documents_bulk_download.update!(
        status: DocumentsBulkDownload::COMPLETED,
        completed_at: Time.current
      )
      old_documents_bulk_download.update_columns(
        created_at: 8.days.ago,
        updated_at: 8.days.ago,
        last_download_at: 8.days.ago
      )

      fresh_documents_bulk_download = DocumentsBulkDownload.create!(
        checksum: 'fresh-download-zip',
        document_ids: [ 14949 ]
      )
      fresh_documents_bulk_download.zip_file.attach(
        io: StringIO.new('fresh zip'),
        filename: 'fresh-elibrary-documents.zip',
        content_type: 'application/zip'
      )
      fresh_documents_bulk_download.update!(
        status: DocumentsBulkDownload::COMPLETED,
        completed_at: Time.current
      )
      fresh_documents_bulk_download.update_columns(last_download_at: 1.day.ago)

      expect do
        described_class.perform_now
      end.to change(DocumentsBulkDownload, :count).by(-1)
        .and change(ActiveStorage::Attachment, :count).by(-1)
        .and change(ActiveStorage::Blob, :count).by(-1)

      expect(DocumentsBulkDownload.exists?(old_documents_bulk_download.id)).to eq(false)
      expect(DocumentsBulkDownload.exists?(fresh_documents_bulk_download.id)).to eq(true)
      expect(fresh_documents_bulk_download.reload.zip_file).to be_attached
    end

    it 'falls back to created_at when last_download_at is nil' do
      stale_documents_bulk_download = DocumentsBulkDownload.create!(
        checksum: 'stale-pending-download-zip',
        document_ids: [ 14903 ]
      )
      stale_documents_bulk_download.update_columns(
        created_at: 3.days.ago,
        updated_at: 3.days.ago,
        last_download_at: nil
      )

      expect do
        described_class.perform_now(2)
      end.to change(DocumentsBulkDownload, :count).by(-1)
    end

    it 'supports a custom retention window' do
      old_documents_bulk_download = DocumentsBulkDownload.create!(
        checksum: 'custom-window-download-zip',
        document_ids: [ 14903 ]
      )
      old_documents_bulk_download.update_columns(
        created_at: 3.days.ago,
        updated_at: 3.days.ago,
        last_download_at: 3.days.ago
      )

      expect do
        described_class.perform_now(2)
      end.to change(DocumentsBulkDownload, :count).by(-1)
    end
  end
end
