FactoryBot.define do

  factory :document do
    date { Date.today }
    filename { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv')) }
    designation
    event
    type 'Document'
    is_public false

    factory :review_of_significant_trade, class: Document::ReviewOfSignificantTrade do
      type 'Document::ReviewOfSignificantTrade'
    end
    factory :proposal, class: Document::Proposal do
      type 'Document::Proposal'
    end
    factory :commission_note, class: Document::CommissionNotes do
      type 'Document::CommissionNotes'
    end

    # After upgrade to Rails 5 and Carrierwave 2, using factory syntax `filename { Rack::Test::UploadedFile.new(...) }`
    # doesn't write the file to the correct location in the file system for unknown reason.
    # This hacking callback copy the file to the correct location.
    after :create do |document|
      dummy_path = File.join(Rails.root, 'spec', 'support', 'annual_report_upload_exporter.csv')
      FileUtils.mkdir_p(document.filename.store_dir)
      FileUtils.cp(dummy_path, document.filename.store_dir)
    end
  end

  factory :document_citation do
    document
  end

  factory :document_citation_taxon_concept do
    document_citation
    taxon_concept
  end

  factory :document_citation_geo_entity do
    document_citation
    geo_entity
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
