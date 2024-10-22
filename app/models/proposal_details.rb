# == Schema Information
#
# Table name: proposal_details
#
#  id                  :integer          not null, primary key
#  proposal_nature     :text
#  proposal_number     :text
#  representation      :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  document_id         :integer
#  proposal_outcome_id :integer
#
# Indexes
#
#  index_proposal_details_on_proposal_outcome_id  (proposal_outcome_id)
#
# Foreign Keys
#
#  proposal_details_document_id_fk          (document_id => documents.id) ON DELETE => cascade
#  proposal_details_proposal_outcome_id_fk  (proposal_outcome_id => document_tags.id)
#

class ProposalDetails < ApplicationRecord
  # Used in DocumentsController
  # attr_accessible :document_id, :proposal_nature, :proposal_outcome_id,
  #   :representation, :proposal_number
  self.table_name = 'proposal_details'
  belongs_to :document, touch: true
end
