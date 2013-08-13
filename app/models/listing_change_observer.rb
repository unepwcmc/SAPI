class ListingChangeObserver < ActiveRecord::Observer

  def before_save(listing_change)
    original_change_type = ChangeType.find(listing_change.change_type_id)
    return listing_change if original_change_type.name == ChangeType::EXCEPTION
    new_exclusions = []
    exclusion_change_type = ChangeType.find_by_name_and_designation_id(
      ChangeType::EXCEPTION, original_change_type.designation_id
    )

    #geographic exclusions
    excluded_geo_entities_ids = listing_change.excluded_geo_entities_ids && 
      listing_change.excluded_geo_entities_ids.compact
    excluded_geo_entities = if excluded_geo_entities_ids && excluded_geo_entities_ids.size > 0
      new_exclusions << ListingChange.new(
        :change_type_id => exclusion_change_type.id,
        :species_listing_id => listing_change.species_listing_id,
        :taxon_concept_id => listing_change.taxon_concept_id,
        :geo_entity_ids => excluded_geo_entities_ids
      )
    end

    #taxonomic exclusions
    excluded_taxon_concepts_ids = listing_change.excluded_taxon_concepts_ids &&
      listing_change.excluded_taxon_concepts_ids.split(',').compact
    excluded_taxon_concepts = if excluded_taxon_concepts_ids && excluded_taxon_concepts_ids.size > 0
      excluded_taxon_concepts_ids.map do |id|
        new_exclusions << ListingChange.new(
          :change_type_id => exclusion_change_type.id,
          :species_listing_id => listing_change.species_listing_id,
          :taxon_concept_id => id
        )
      end
    end

    listing_change.exclusions = new_exclusions
  end

end