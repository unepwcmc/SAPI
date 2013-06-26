class MTaxonConceptFilterByAppendixPopulationQuery < MTaxonConceptFilterByAppendixQuery

  def initialize(relation = MTaxonConcept.scoped, appendix_abbreviations = [], geo_entities_ids = [])
    @relation = relation
    @appendix_abbreviations = appendix_abbreviations
    @geo_entities_ids = GeoEntity.nodes_and_descendants(geo_entities_ids).map(&:id)
    @geo_entities_in_clause = @geo_entities_ids.compact.join(',')
  end

  def relation(designation_name = 'CITES')
    initialize_species_listings_conditions(designation_name)
    @relation.joins(
      <<-SQL
      INNER JOIN (
        -- listed in specified geo entities
        SELECT taxon_concept_id
        FROM listing_changes_mview
        INNER JOIN listing_distributions ON listing_changes_mview.id = listing_distributions.listing_change_id AND NOT is_party
        WHERE is_current = 't' AND change_type_name = 'ADDITION'
        AND listing_distributions.geo_entity_id IN (#{@geo_entities_in_clause})
        #{"AND species_listing_id IN (#{@species_listings_in_clause})" unless @appendix_abbreviations.empty?}

        UNION
        (
          -- not on level of listing but occurs in specified geo entities
          SELECT taxon_concepts_mview.id
          FROM taxon_concepts_mview
          INNER JOIN distributions
            ON distributions.taxon_concept_id = taxon_concepts_mview.id
          WHERE distributions.geo_entity_id IN (#{@geo_entities_in_clause})
          AND cites_listed = FALSE
          #{"AND (#{@appendix_abbreviations_conditions})" unless @appendix_abbreviations.empty? }
        )

        UNION
        (
          -- occurs in specified geo entities
          SELECT distributions.taxon_concept_id
          FROM distributions
          WHERE distributions.geo_entity_id IN (#{@geo_entities_in_clause})

          INTERSECT

          -- has listing changes that do not have distribution attached
          SELECT taxon_concept_id
          FROM listing_changes_mview
          LEFT JOIN listing_distributions ON listing_changes_mview.id = listing_distributions.listing_change_id AND NOT is_party
          WHERE is_current = 't' AND change_type_name = 'ADDITION'
          #{"AND species_listing_id IN (#{@species_listings_in_clause})" unless @appendix_abbreviations.empty? }
          AND listing_distributions.id IS NULL

          EXCEPT

          -- and does not have an exclusion for the specified geo entities
          (
          #{
            @geo_entities_ids.map do |geo_entity_id|
              <<-GEO_SQL
                SELECT taxon_concept_id
                FROM listing_changes_mview
                INNER JOIN listing_distributions ON listing_changes_mview.id = listing_distributions.listing_change_id AND NOT is_party
                WHERE is_current = 't' AND change_type_name = 'EXCEPTION'
                #{"AND species_listing_id IN (#{@species_listings_in_clause})" unless @appendix_abbreviations.empty? }
                AND listing_distributions.geo_entity_id = #{geo_entity_id}
              GEO_SQL
            end.join ("\n            INTERSECT\n\n")
          }
          )

        )
      ) taxa_in_populations ON #{@relation.table_name}.id = taxa_in_populations.taxon_concept_id
      SQL
    )
  end

end
