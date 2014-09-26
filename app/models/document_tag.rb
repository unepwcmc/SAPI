# == Schema Information
#
# Table name: document_tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  type       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DocumentTag < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :documents

  scope :review_phases, -> { where(type: 'DocumentTag::ReviewPhase') }
  scope :proposal_outcomes, -> { where(type: 'DocumentTag::ProposalOutcome') }
end
