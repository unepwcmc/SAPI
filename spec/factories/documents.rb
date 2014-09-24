FactoryGirl.define do

  factory :document do
    date { Date.today }
    filename { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv')) }
    event
    type 'Document'

    factory :review_of_significant_trade, class: Document::ReviewOfSignificantTrade do
      type 'Document::ReviewOfSignificantTrade'
    end
    factory :proposal, class: Document::Proposal do
      type 'Document::Proposal'
    end
  end

  factory :document_citation do
    document_id 1
  end

  factory :proposal_details, class: Document::ProposalDetails do
    document
    proposal_outcome
  end

  factory :review_details, class: Document::ReviewDetails do
    document
    review_phase
  end

end
