class DocumentCitation < ActiveRecord::Base
  track_who_does_it
  attr_accessible :document_id, :stringy_taxon_concept_ids, :geo_entity_ids
  has_many :document_citation_taxon_concepts, dependent: :destroy
  has_many :taxon_concepts, through: :document_citation_taxon_concepts
  has_many :document_citation_geo_entities, dependent: :destroy
  has_many :geo_entities, through: :document_citation_geo_entities

  # the following two amazing methods are here to handle input from select2
  # which in case of ajax populated multiple selects comes as a comma sep list
  def stringy_taxon_concept_ids
    taxon_concept_ids.join(',')
  end

  def stringy_taxon_concept_ids=(ids)
    self.taxon_concept_ids = ids.split(',')
  end

end
