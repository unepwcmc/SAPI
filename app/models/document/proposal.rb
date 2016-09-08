# == Schema Information
#
# Table name: documents
#
#  id                           :integer          not null, primary key
#  title                        :text             not null
#  filename                     :text             not null
#  date                         :date             not null
#  type                         :string(255)      not null
#  is_public                    :boolean          default(FALSE), not null
#  event_id                     :integer
#  language_id                  :integer
#  elib_legacy_id               :integer
#  created_by_id                :integer
#  updated_by_id                :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  sort_index                   :integer
#  primary_language_document_id :integer
#  elib_legacy_file_name        :text
#  original_id                  :integer
#  discussion_id                :integer
#  discussion_sort_index        :integer
#  designation_id               :integer
#

class Document::Proposal < Document
  def self.display_name
    'Proposal'
  end

  attr_accessible :proposal_details_attributes

  has_one :proposal_details,
    :class_name => 'Document::ProposalDetails',
    :foreign_key => 'document_id',
    dependent: :destroy
  accepts_nested_attributes_for :proposal_details, :allow_destroy => true
end
