# == Schema Information
#
# Table name: documents
#
#  id                           :integer          not null, primary key
#  date                         :date             not null
#  discussion_sort_index        :integer
#  elib_legacy_file_name        :text
#  filename                     :text             not null
#  general_subtype              :boolean
#  is_public                    :boolean          default(FALSE), not null
#  sort_index                   :integer
#  title                        :text             not null
#  type                         :string(255)      not null
#  volume                       :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  created_by_id                :integer
#  designation_id               :integer
#  discussion_id                :integer
#  elib_legacy_id               :integer
#  event_id                     :integer
#  language_id                  :integer
#  manual_id                    :text
#  original_id                  :integer
#  primary_language_document_id :integer
#  updated_by_id                :integer
#
# Indexes
#
#  index_documents_on_created_by_id                                 (created_by_id)
#  index_documents_on_designation_id                                (designation_id)
#  index_documents_on_event_id                                      (event_id)
#  index_documents_on_language_id                                   (language_id)
#  index_documents_on_language_id_and_primary_language_document_id  (language_id,primary_language_document_id) UNIQUE
#  index_documents_on_original_id                                   (original_id)
#  index_documents_on_primary_language_document_id                  (primary_language_document_id)
#  index_documents_on_title_to_ts_vector                            (to_tsvector('simple'::regconfig, COALESCE(title, ''::text))) USING gin
#  index_documents_on_updated_by_id                                 (updated_by_id)
#
# Foreign Keys
#
#  documents_created_by_id_fk                 (created_by_id => users.id)
#  documents_designation_id_fk                (designation_id => designations.id) ON DELETE => nullify
#  documents_event_id_fk                      (event_id => events.id)
#  documents_language_id_fk                   (language_id => languages.id)
#  documents_original_id_fk                   (original_id => documents.id) ON DELETE => nullify
#  documents_primary_language_document_id_fk  (primary_language_document_id => documents.id) ON DELETE => nullify
#  documents_updated_by_id_fk                 (updated_by_id => users.id)
#

class Document::Proposal < Document
  def self.display_name
    'Proposal'
  end

  # Used in Document Controller
  # attr_accessible :proposal_details_attributes

  has_one :proposal_details,
    class_name: 'ProposalDetails',
    foreign_key: 'document_id',
    dependent: :destroy
  accepts_nested_attributes_for :proposal_details, allow_destroy: true
end
