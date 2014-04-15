class Species::AutocompleteTaxonConceptSerializer < ActiveModel::Serializer
  attributes :id, :full_name, :rank_name, :matching_names, :accepted_subspecies

  def matching_names
    (object.synonyms + object.english_names +
      object.french_names + object.spanish_names).sort
  end

  def accepted_subspecies
    taxon_concept = MTaxonConcept.find(object.id)
    object.rank_name == 'SUBSPECIES' && 
    (taxon_concept.taxonomy_is_cites_eu? && taxon_concept.cites_listed?) ||
    taxon_concept.cms_listed?
  end
end
