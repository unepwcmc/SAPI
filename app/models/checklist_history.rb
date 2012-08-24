class ChecklistHistory < Checklist

  def initialize(options={})
    super(options.merge({:output_layout => :taxonomic}))
    select_values = [
      "taxon_concepts.id", :data,
      "listing_changes.effective_at",
      "listing_changes.notes AS listing_notes",
      "change_types.name AS change_type",
      "species_listings.abbreviation AS species_listing",
      "geo_entities.iso_code2 AS party"
    ]
    (options[:common_names] || []).each do |lng|
      select_values << "lng_#{lng.downcase}"
    end
    @taxon_concepts_rel.select_values = select_values

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
        geo_entities.id = listing_distributions.geo_entity_id").
      #filter out deletion records that were added programatically to simplify
      #current listing calculations - don't want them to show up
      where("NOT (change_types.name = '#{ChangeType::DELETION}' AND species_listing_id IS NOT NULL)").
      #filter out 'Subspecies xxx only' listings, as they should not show up in history
      where("NOT (data->'rank_name' = 'SPECIES' AND listing_changes.notes LIKE 'Subspecies%only')").
      #within the same effective date, listing changes should be ordered by operation
      order("CASE
        WHEN change_types.name = 'ADDITION' THEN 0
        WHEN change_types.name = 'RESERVATION' THEN 1
        WHEN change_types.name = 'RESERVATION_WITHDRAWAL' THEN 2
        WHEN change_types.name = 'DELETION' THEN 3
      END")
  end

end