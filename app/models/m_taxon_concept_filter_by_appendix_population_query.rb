class MTaxonConceptFilterByAppendixPopulationQuery < MTaxonConceptFilterByAppendixQuery

  def initialize(relation, appendix_abbreviations, geo_entities_ids = [])
    @relation = relation || MTaxonConcept.scoped
    @appendix_abbreviations = appendix_abbreviations || []
    @original_geo_entities_ids = geo_entities_ids
    @geo_entities_ids = GeoEntity.nodes_and_descendants(geo_entities_ids).map(&:id)
    @geo_entities_in_clause = @geo_entities_ids.compact.join(',')
    @table = @relation.from_value || 'taxon_concepts_mview'
  end

  def relation(designation_name = 'CITES')
    unless ['cites', 'eu', 'cms'].include? designation_name.downcase
      designation_name = 'CITES'
    end
    listing_changes_mview = "#{designation_name.downcase}_listing_changes_mview"
    initialize_species_listings_conditions(designation_name)
    @relation.joins(
      <<-SQL
      INNER JOIN (
        -- listed in specified geo entities
        SELECT DISTINCT original_taxon_concept_id AS taxon_concept_id
        FROM #{listing_changes_mview} listing_changes_mview
        INNER JOIN listing_distributions ON listing_changes_mview.id = listing_distributions.listing_change_id AND NOT is_party
        WHERE is_current = 't' AND change_type_name = 'ADDITION'
        AND listing_distributions.geo_entity_id IN (#{@geo_entities_in_clause})
        #{"AND species_listing_id IN (#{@species_listings_in_clause})" unless @appendix_abbreviations.empty?}

        UNION
        (
          -- not on level of listing but occurs in specified geo entities
          SELECT #{@table}.id
          FROM #{@table}
          INNER JOIN distributions
            ON distributions.taxon_concept_id = #{@table}.id
          WHERE distributions.geo_entity_id IN (#{@geo_entities_in_clause})
          AND #{designation_name.downcase}_listed = FALSE
          #{"AND (#{@appendix_abbreviations_conditions})" unless @appendix_abbreviations.empty? }
        )

        UNION
        (
          -- has listing changes that do not have distribution attached
          SELECT DISTINCT original_taxon_concept_id AS taxon_concept_id
          FROM #{listing_changes_mview} listing_changes_mview
          LEFT JOIN listing_distributions ON listing_changes_mview.id = listing_distributions.listing_change_id AND NOT is_party
          WHERE is_current = 't' AND change_type_name = 'ADDITION'
          #{"AND species_listing_id IN (#{@species_listings_in_clause})" unless @appendix_abbreviations.empty? }
          AND listing_distributions.id IS NULL

          INTERSECT

          -- and does not have an exclusion for the geo entities where it occurs
          (
            SELECT DISTINCT tmp.taxon_concept_id
            FROM (
                  select taxon_concept_id, geo_entity_id
                  FROM distributions
                  WHERE distributions.geo_entity_id IN (#{@geo_entities_in_clause})

            EXCEPT
            (
              SELECT DISTINCT listing_changes_mview.original_taxon_concept_id AS taxon_concept_id, listing_distributions.geo_entity_id as geo_entity_id
              FROM #{listing_changes_mview} listing_changes_mview
              INNER JOIN #{listing_changes_mview} parent_listing_changes_mview
              ON parent_listing_changes_mview.id = listing_changes_mview.parent_id 
              AND parent_listing_changes_mview.is_current 
              AND parent_listing_changes_mview.change_type_name = 'ADDITION'
              INNER JOIN listing_distributions ON listing_changes_mview.id = listing_distributions.listing_change_id AND NOT is_party
              WHERE listing_changes_mview.change_type_name = 'EXCEPTION'
              #{"AND listing_changes_mview.species_listing_id IN (#{@species_listings_in_clause})" unless @appendix_abbreviations.empty? }
              AND listing_distributions.geo_entity_id IN (#{@geo_entities_in_clause})
            )
            ) as tmp
          )

        )
      ) taxa_in_populations ON #{@table}.id = taxa_in_populations.taxon_concept_id
      SQL
    )
  end

end
