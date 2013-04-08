CREATE OR REPLACE FUNCTION rebuild_explicit_eu_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    UPDATE taxon_concepts SET listing =
    CASE
    WHEN NOT (taxon_concepts.listing->'eu_status_original')::BOOLEAN
    THEN taxon_concepts.listing - ARRAY['eu_not_listed']
    ELSE taxon_concepts.listing
    END || qqq.listing
    FROM (
      SELECT taxon_concept_id, listing ||
      hstore('eu_listing_original', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[listing -> 'eu_A', listing -> 'eu_B', listing -> 'eu_C', listing -> 'eu_D']) s 
          WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM (
        SELECT taxon_concept_id, 
          hstore('eu_A', CASE WHEN SUM(eu_A) > 0 THEN 'A' ELSE NULL END) ||
          hstore('eu_B', CASE WHEN SUM(eu_B) > 0 THEN 'B' ELSE NULL END) ||
          hstore('eu_C', CASE WHEN SUM(eu_C) > 0 THEN 'C' ELSE NULL END) ||
          hstore('eu_D', CASE WHEN SUM(eu_D) > 0 THEN 'D' ELSE NULL END)
          AS listing
        FROM (
          SELECT taxon_concept_id, effective_at, species_listings.abbreviation, change_types.name AS change_type,
          CASE
            WHEN species_listings.abbreviation = 'A' AND change_types.name = 'ADDITION' THEN 1
            WHEN (species_listings.abbreviation = 'A' OR species_listing_id IS NULL)
              AND change_types.name = 'DELETION' THEN -1
            ELSE 0
          END AS eu_A,
          CASE
            WHEN species_listings.abbreviation = 'B' AND change_types.name = 'ADDITION' THEN 1
            WHEN (species_listings.abbreviation = 'B' OR species_listing_id IS NULL)
              AND change_types.name = 'DELETION' THEN -1
            ELSE 0
          END AS eu_B,
          CASE
            WHEN species_listings.abbreviation = 'C' AND change_types.name = 'ADDITION' THEN 1
            WHEN (species_listings.abbreviation = 'C' OR species_listing_id IS NULL)
              AND change_types.name = 'DELETION' AND
                (listing_distributions.id IS NULL OR NOT listing_distributions.is_party) THEN -1
            ELSE 0
          END AS eu_C,
          CASE
            WHEN species_listings.abbreviation = 'D' AND change_types.name = 'ADDITION' THEN 1
            WHEN (species_listings.abbreviation = 'D' OR species_listing_id IS NULL)
              AND change_types.name = 'DELETION' AND
                (listing_distributions.id IS NULL OR NOT listing_distributions.is_party) THEN -1
            ELSE 0
          END AS eu_D
          FROM listing_changes
          INNER JOIN change_types ON change_type_id = change_types.id
            AND change_types.name IN ('ADDITION','DELETION')
          INNER JOIN  designations ON change_types.designation_id = designations.id
            AND designations.name = 'EU'
          INNER JOIN species_listings ON species_listing_id = species_listings.id
          LEFT JOIN listing_distributions
            ON listing_distributions.listing_change_id = listing_changes.id
          WHERE effective_at <= NOW() AND is_current = 't'
        ) AS q
        GROUP BY taxon_concept_id
      ) AS qq
    ) AS qqq
    WHERE taxon_concepts.id = qqq.taxon_concept_id AND
    CASE WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id ELSE TRUE END;
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_explicit_eu_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_explicit_eu_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_explicit_eu_listing() IS '
Procedure to rebuild explicit EU listing in taxon_concepts.
';
