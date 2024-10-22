class MTaxonConceptFilterByAppendixPopulationQuery < MTaxonConceptFilterByAppendixQuery
  def initialize(relation, appendix_abbreviations, geo_entities_ids = [])
    @relation = relation || MTaxonConcept.all
    @appendix_abbreviations = appendix_abbreviations || []
    @original_geo_entities_ids = geo_entities_ids
    @geo_entities_ids = GeoEntity.nodes_and_descendants(geo_entities_ids).map(&:id)
    @geo_entities_in_clause = @geo_entities_ids.compact.join(',')
    @table = @relation.from_clause.value || 'taxon_concepts_mview'
  end

  def relation(designation_name = 'CITES')
    unless [ 'CITES', 'EU', 'CMS' ].include? designation_name
      designation_name = 'CITES'
    end

    listing_changes_mview = "#{designation_name.downcase}_listing_changes_mview"

    initialize_species_listings_conditions(designation_name)

    # Filter all current additions where either
    #
    # - The listing does not specify which population the listing applies to
    #   (and thus applies to all)
    # - at least one member in common between the `listed_geo_entities_ids` of
    #   the listing and and `@geo_entities_ids`.
    #
    # And where the listing change does not specify excluded populations or
    # whose excluded populations (in the case of genus-level listings, where
    # the species in question is known to have such a population) do not include
    # all members of `@geo_entities_ids`
    @relation.joins(
      <<-SQL.squish
      JOIN (
        SELECT taxon_concept_id
        FROM #{listing_changes_mview} lc
        JOIN #{@table} tc ON lc.taxon_concept_id = tc.id
        WHERE is_current = 't' AND change_type_name = 'ADDITION'
        AND (
          listed_geo_entities_ids && ARRAY[#{@geo_entities_in_clause}]
          OR ARRAY_UPPER(listed_geo_entities_ids, 1) IS NULL
        ) AND NOT excluded_geo_entities_ids @> array_intersect(countries_ids_ary, ARRAY[#{@geo_entities_in_clause}])
        #{"AND species_listing_id IN (#{@species_listings_in_clause})" unless @appendix_abbreviations.empty?}
        GROUP BY taxon_concept_id
      ) matching_listing_changes
      ON #{@table}.id = matching_listing_changes.taxon_concept_id
      SQL
    ).where(
      "countries_ids_ary && ARRAY[#{@geo_entities_in_clause}]"
    )
  end
end
