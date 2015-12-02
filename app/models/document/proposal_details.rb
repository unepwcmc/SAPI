# == Schema Information
#
# Table name: proposal_details
#
#  id                  :integer          not null, primary key
#  document_id         :integer
#  proposal_nature     :text
#  proposal_outcome_id :integer
#  representation      :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Document::ProposalDetails < ActiveRecord::Base
  attr_accessible :document_id, :proposal_nature, :proposal_outcome_id, :representation
  self.table_name = 'proposal_details'
  belongs_to :document, touch: true
end
