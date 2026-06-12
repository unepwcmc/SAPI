require 'spec_helper'

RSpec.describe PurgeDownloadZipCacheJob do
  before(:each) do
    DownloadZip.find_each do |download_zip|
      download_zip.zip_file.purge if download_zip.zip_file.attached?
    end
    DownloadZip.delete_all
  end

  describe '#perform' do
    it 'removes old cached download zips and keeps newer ones' do
      old_download_zip = DownloadZip.create!(
        checksum: 'old-download-zip',
        document_ids: [ 14903 ]
      )
      old_download_zip.zip_file.attach(
        io: StringIO.new('old zip'),
        filename: 'old-elibrary-documents.zip',
        content_type: 'application/zip'
      )
      old_download_zip.update!(
        status: DownloadZip::COMPLETED,
        completed_at: Time.current
      )
      old_download_zip.update_columns(
        created_at: 8.days.ago,
        updated_at: 8.days.ago,
        last_download_at: 8.days.ago
      )

      fresh_download_zip = DownloadZip.create!(
        checksum: 'fresh-download-zip',
        document_ids: [ 14949 ]
      )
      fresh_download_zip.zip_file.attach(
        io: StringIO.new('fresh zip'),
        filename: 'fresh-elibrary-documents.zip',
        content_type: 'application/zip'
      )
      fresh_download_zip.update!(
        status: DownloadZip::COMPLETED,
        completed_at: Time.current
      )
      fresh_download_zip.update_columns(last_download_at: 1.day.ago)

      expect do
        described_class.perform_now
      end.to change(DownloadZip, :count).by(-1)
        .and change(ActiveStorage::Attachment, :count).by(-1)
        .and change(ActiveStorage::Blob, :count).by(-1)

      expect(DownloadZip.exists?(old_download_zip.id)).to eq(false)
      expect(DownloadZip.exists?(fresh_download_zip.id)).to eq(true)
      expect(fresh_download_zip.reload.zip_file).to be_attached
    end

    it 'falls back to created_at when last_download_at is nil' do
      stale_pending_download_zip = DownloadZip.create!(
        checksum: 'stale-pending-download-zip',
        document_ids: [ 14903 ]
      )
      stale_pending_download_zip.update_columns(
        created_at: 3.days.ago,
        updated_at: 3.days.ago,
        last_download_at: nil
      )

      expect do
        described_class.perform_now(2)
      end.to change(DownloadZip, :count).by(-1)
    end

    it 'supports a custom retention window' do
      old_download_zip = DownloadZip.create!(
        checksum: 'custom-window-download-zip',
        document_ids: [ 14903 ]
      )
      old_download_zip.update_columns(
        created_at: 3.days.ago,
        updated_at: 3.days.ago,
        last_download_at: 3.days.ago
      )

      expect do
        described_class.perform_now(2)
      end.to change(DownloadZip, :count).by(-1)
    end
  end
end
