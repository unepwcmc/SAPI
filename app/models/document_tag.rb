# == Schema Information
#
# Table name: document_tags
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DocumentTag < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :documents

  scope :review_phases, -> { where(type: 'DocumentTag::ReviewPhase') }
  scope :process_stages, -> { where(type: 'DocumentTag::ProcessStage') }
  scope :proposal_outcomes, -> { where(type: 'DocumentTag::ProposalOutcome') }
end
