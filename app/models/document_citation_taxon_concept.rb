# == Schema Information
#
# Table name: document_citation_taxon_concepts
#
#  id                   :integer          not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  document_citation_id :integer
#  taxon_concept_id     :integer
#  updated_by_id        :integer
#
# Indexes
#
#  index_citation_taxon_concepts_on_taxon_concept_id_citation_id  (taxon_concept_id,document_citation_id) UNIQUE
#
# Foreign Keys
#
#  document_citation_taxon_concepts_created_by_id_fk         (created_by_id => users.id)
#  document_citation_taxon_concepts_document_citation_id_fk  (document_citation_id => document_citations.id)
#  document_citation_taxon_concepts_taxon_concept_id_fk      (taxon_concept_id => taxon_concepts.id)
#  document_citation_taxon_concepts_updated_by_id_fk         (updated_by_id => users.id)
#

class DocumentCitationTaxonConcept < ApplicationRecord
  include TrackWhoDoesIt
  # Used by other models, not controllers.
  # attr_accessible :created_by_id, :document_citation_id, :taxon_concept_id, :updated_by_id,
  #   :updated_at

  belongs_to :taxon_concept
  belongs_to :document_citation, touch: true
  validates :taxon_concept_id, uniqueness: {
    scope: :document_citation_id,
    message: 'taxon_concept citation already present'
  }

  after_destroy do |dc_tc|
    dc_tc.document_citation.touch
  end
end
