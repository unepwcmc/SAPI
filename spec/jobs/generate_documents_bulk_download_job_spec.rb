require 'spec_helper'

RSpec.describe GenerateDocumentsBulkDownloadJob do
  before(:each) do
    DocumentsBulkDownload.find_each do |documents_bulk_download|
      documents_bulk_download.zip_file.purge if documents_bulk_download.zip_file.attached?
    end
    DocumentsBulkDownload.delete_all
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
      documents_bulk_download = DocumentsBulkDownload.create!(
        checksum: 'checksum-with-missing-file',
        document_ids: [ missing_document.id, attached_document.id ]
      )

      described_class.perform_now(documents_bulk_download.id)

      documents_bulk_download.reload

      expect(documents_bulk_download.status).to eq(DocumentsBulkDownload::COMPLETED)
      expect(documents_bulk_download.processing_at).to be_present
      expect(documents_bulk_download.completed_at).to be_present
      expect(documents_bulk_download.zip_file).to be_attached
      expect(
        ActiveStorage::Attachment.exists?(
          record_type: 'DocumentsBulkDownload',
          record_id: documents_bulk_download.id,
          name: 'zip_file'
        )
      ).to eq(true)

      Zip::File.open_buffer(documents_bulk_download.zip_file.download) do |zip_file|
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
      documents_bulk_download = DocumentsBulkDownload.create!(
        checksum: 'checksum-without-attachments',
        document_ids: [ missing_document.id, attached_document.id ]
      )

      expect do
        described_class.perform_now(documents_bulk_download.id)
      end.to raise_error('No documents available to generate ZIP')

      documents_bulk_download.reload

      expect(documents_bulk_download.status).to eq(DocumentsBulkDownload::FAILED)
      expect(documents_bulk_download.error_message).to eq('No documents available to generate ZIP')
      expect(documents_bulk_download.zip_file).not_to be_attached
    end

    it 'returns early when the zip is already attached and completed' do
      documents_bulk_download = DocumentsBulkDownload.create!(
        checksum: 'checksum-already-completed',
        document_ids: [ attached_document.id ]
      )
      documents_bulk_download.zip_file.attach(
        io: StringIO.new('existing zip'),
        filename: 'elibrary-documents.zip',
        content_type: 'application/zip'
      )
      documents_bulk_download.update!(
        status: DocumentsBulkDownload::COMPLETED,
        completed_at: Time.current
      )

      processing_at = documents_bulk_download.processing_at
      completed_at = documents_bulk_download.completed_at

      described_class.perform_now(documents_bulk_download.id)

      documents_bulk_download.reload

      expect(documents_bulk_download.status).to eq(DocumentsBulkDownload::COMPLETED)
      expect(documents_bulk_download.processing_at).to eq(processing_at)
      expect(documents_bulk_download.completed_at.to_i).to eq(completed_at.to_i)
      expect(documents_bulk_download.zip_file).to be_attached
    end
  end
end
