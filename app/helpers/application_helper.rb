module ApplicationHelper

  def speciesplus_taxon_concept_id_url(taxon_concept_id)
    speciesplus_taxon_concept_url(TaxonConcept.find_by_id(taxon_concept_id))
  end

  def speciesplus_taxon_concept_url(taxon_concept)
    return nil unless taxon_concept
    if [Rank::SPECIES, Rank::SUBSPECIES].include?(taxon_concept.rank.name)
      "/species#/taxon_concepts/#{taxon_concept.id}/legal"
    else
      taxonomy = taxon_concept.taxonomy.name.downcase
      "/species#/taxon_concepts?taxonomy=#{taxonomy}&taxon_concept_query=#{taxon_concept.full_name}"
    end
  end

end
