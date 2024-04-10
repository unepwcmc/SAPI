require 'spec_helper'

describe DocumentBatch, sidekiq: :inline do

  describe :save do
    context "when invalid" do
      subject {
        DocumentBatch.new(
          documents_attributes: {
            '0' => { type: 'Document' }
          },
          files: [
            filename: Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv'))
          ]
        )
      }
      specify { expect(subject.save).to be_falsey }
      specify { expect { subject.save }.not_to change { Document.count } }
    end
    context "when valid" do
      subject {
        DocumentBatch.new(
          date: Date.today,
          documents_attributes: {
            '0' => { type: 'Document' }
          },
          files: [
            Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv'))
          ]
        )
      }
      specify { expect(subject.save).to be_truthy }
      specify { expect { subject.save }.to change { Document.count }.by(1) }
    end
  end
end
