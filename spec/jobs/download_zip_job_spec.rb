require 'spec_helper'

RSpec.describe DownloadZipJob do
  before(:each) do
    DownloadZip.find_each do |download_zip|
      download_zip.zip_file.purge if download_zip.zip_file.attached?
    end
    DownloadZip.delete_all
  end

  let(:attached_document) do
    create(:proposal, is_public: true, event: nil, designation: nil)
  end
  let(:missing_document) do
    create(:proposal, is_public: true, event: nil, designation: nil)
  end

  describe '#perform' do
    it 'builds a zip, attaches it, and includes missing_files.txt when needed' do
      missing_document.file.purge
      download_zip = DownloadZip.create!(
        checksum: 'checksum-with-missing-file',
        document_ids: [ missing_document.id, attached_document.id ]
      )

      described_class.perform_now(download_zip.id)

      download_zip.reload

      expect(download_zip.status).to eq(DownloadZip::COMPLETED)
      expect(download_zip.processing_at).to be_present
      expect(download_zip.completed_at).to be_present
      expect(download_zip.zip_file).to be_attached
      expect(
        ActiveStorage::Attachment.exists?(
          record_type: 'DownloadZip',
          record_id: download_zip.id,
          name: 'zip_file'
        )
      ).to eq(true)

      Zip::File.open_buffer(download_zip.zip_file.download) do |zip_file|
        expect(zip_file.map(&:name)).to contain_exactly(
          attached_document.file.filename.to_s,
          'missing_files.txt'
        )
        expect(zip_file.read('missing_files.txt')).to include(missing_document.title)
      end
    end

    it 'marks the request as failed when no files can be zipped' do
      missing_document.file.purge
      attached_document.file.purge
      download_zip = DownloadZip.create!(
        checksum: 'checksum-without-attachments',
        document_ids: [ missing_document.id, attached_document.id ]
      )

      expect do
        described_class.perform_now(download_zip.id)
      end.to raise_error('No documents available to generate ZIP')

      download_zip.reload

      expect(download_zip.status).to eq(DownloadZip::FAILED)
      expect(download_zip.error_message).to eq('No documents available to generate ZIP')
      expect(download_zip.zip_file).not_to be_attached
    end

    it 'returns early when the zip is already attached and completed' do
      download_zip = DownloadZip.create!(
        checksum: 'checksum-already-completed',
        document_ids: [ attached_document.id ],
        status: DownloadZip::COMPLETED,
        completed_at: Time.current
      )
      download_zip.zip_file.attach(
        io: StringIO.new('existing zip'),
        filename: 'elibrary-documents.zip',
        content_type: 'application/zip'
      )
      download_zip.save!

      processing_at = download_zip.processing_at
      completed_at = download_zip.completed_at

      described_class.perform_now(download_zip.id)

      download_zip.reload

      expect(download_zip.status).to eq(DownloadZip::COMPLETED)
      expect(download_zip.processing_at).to eq(processing_at)
      expect(download_zip.completed_at.to_i).to eq(completed_at.to_i)
      expect(download_zip.zip_file).to be_attached
    end
  end
end
