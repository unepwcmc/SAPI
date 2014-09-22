FactoryGirl.define do

  factory :document_tag do
    name 'You taaaag'
    factory :review_phase, class: DocumentTag::ReviewPhase do
      type 'DocumentTag::ReviewPhase'
    end
    factory :proposal_outcome, class: DocumentTag::ProposalOutcome do
      type 'DocumentTag::ProposalOutcome'
    end
  end

end
