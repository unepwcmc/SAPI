# == Schema Information
#
# Table name: document_citation_taxon_concepts
#
#  id                   :integer          not null, primary key
#  document_citation_id :integer
#  taxon_concept_id     :integer
#  created_by_id        :integer
#  updated_by_id        :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class DocumentCitationTaxonConcept < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :document_citation_id, :taxon_concept_id, :updated_by_id,
    :updated_at
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
