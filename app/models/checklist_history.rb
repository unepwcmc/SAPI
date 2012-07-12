class ChecklistHistory < Checklist

  def initialize(options={})
    super(options.merge({:output_layout => :taxonomic}))
    @taxon_concepts_rel.select_values = [
      "taxon_concepts.id AS taxon_concept_id", :data,
      "lng_e", "lng_s", "lng_f",
      "listing_changes.effective_at",
      "listing_changes.notes AS listing_notes",
      "change_types.name AS change_type",
      "species_listings.abbreviation AS species_listing",
      "geo_entities.iso_code2 AS party"
    ]
    @taxon_concepts_rel.order_values = [
      :"data -> 'taxonomic_position'", :effective_at
    ]
    @taxon_concepts_rel = @taxon_concepts_rel.
      joins("LEFT JOIN listing_changes
        ON listing_changes.taxon_concept_id = taxon_concepts.id").
      joins("LEFT JOIN change_types
        ON listing_changes.change_type_id = change_types.id").
      joins("LEFT JOIN species_listings
        ON listing_changes.species_listing_id = species_listings.id").
      joins("LEFT JOIN listing_distributions
        ON listing_changes.id = listing_distributions.listing_change_id
        AND listing_distributions.is_party = 't'").
      joins("LEFT JOIN geo_entities ON
        geo_entities.id = listing_distributions.geo_entity_id")
  end

end