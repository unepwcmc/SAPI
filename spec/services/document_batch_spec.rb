require 'spec_helper'

describe DocumentBatch, sidekiq: :inline do
  describe '#initialize' do
    it 'raises when document metadata and uploaded files counts differ' do
      expect do
        DocumentBatch.new(
          date: Date.today,
          documents_attributes: [
            { type: 'Document' },
            { type: 'Document' }
          ],
          files: [
            Rack::Test::UploadedFile.new(
              Rails.root.join(
                'spec/support/annual_report_upload_exporter.csv'
              ).to_s
            )
          ]
        )
      end.to raise_error(
        StandardError,
        'documents_attributes and files should have the same number of elements'
      )
    end
  end

  describe :save do
    context 'when invalid' do
      subject do
        DocumentBatch.new(
          documents_attributes: [
            { type: 'Document' }
          ],
          files: [
            filename: Rack::Test::UploadedFile.new(
              Rails.root.join(
                'spec/support/annual_report_upload_exporter.csv'
              ).to_s
            )
          ]
        )
      end

      specify { expect(subject.save).to be_falsey }
      specify { expect { subject.save }.not_to change(Document, :count) }
    end

    context 'when valid' do
      subject do
        DocumentBatch.new(
          date: Date.today,
          documents_attributes: [
            { type: 'Document' }
          ],
          files: [
            Rack::Test::UploadedFile.new(
              Rails.root.join(
                'spec/support/annual_report_upload_exporter.csv'
              ).to_s
            )
          ]
        )
      end

      specify { expect(subject.save).to be_truthy }
      specify { expect { subject.save }.to change(Document, :count).by(1) }
    end
  end
end
