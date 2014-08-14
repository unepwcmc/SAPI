class DocumentCitationTaxonConcept < ActiveRecord::Base
  track_who_does_it
  attr_accessible :created_by_id, :document_citation_id, :taxon_concept_id, :updated_by_id
  belongs_to :taxon_concept
end
