require 'spec_helper'

RSpec.describe DocumentsBulkDownload, type: :model do
  describe 'completed zip validation' do
    it 'is invalid when completed without an attached zip file' do
      documents_bulk_download = described_class.new(
        checksum: 'completed-without-attachment',
        document_ids: [ 14903 ],
        status: described_class::COMPLETED,
        completed_at: Time.current
      )

      expect(documents_bulk_download).not_to be_valid
      expect(documents_bulk_download.errors[:zip_file]).to include(
        'must be attached when the download zip is completed'
      )
    end
  end
end
