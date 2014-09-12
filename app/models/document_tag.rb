class DocumentTag < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :documents

  scope :review_phases, -> { where(type: 'DocumentTag::ReviewPhase') }
  scope :proposal_outcomes, -> { where(type: 'DocumentTag::ProposalOutcome') }
end
