CREATE OR REPLACE FUNCTION rebuild_explicit_cites_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN

    UPDATE taxon_concepts SET listing =
    CASE
    WHEN NOT (taxon_concepts.listing->'cites_status_original')::BOOLEAN
    THEN taxon_concepts.listing - ARRAY['cites_not_listed']
    ELSE taxon_concepts.listing
    END || qqq.listing
    FROM (
      SELECT taxon_concept_id, listing ||
      hstore('cites_listing_original', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[listing -> 'cites_I', listing -> 'cites_II', listing -> 'cites_III']) s
          WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM (
        SELECT taxon_concept_id,
          hstore('cites_I', CASE WHEN SUM(cites_I) > 0 THEN 'I' ELSE NULL END) ||
          hstore('cites_II', CASE WHEN SUM(cites_II) > 0 THEN 'II' ELSE NULL END) ||
          hstore('cites_III', CASE WHEN SUM(cites_III) > 0 THEN 'III' ELSE NULL END)
          AS listing
        FROM (
          SELECT taxon_concept_id, effective_at, species_listings.abbreviation, change_types.name AS change_type,
          CASE
            WHEN species_listings.abbreviation = 'I' AND change_types.name = 'ADDITION' THEN 1
            WHEN (species_listings.abbreviation = 'I' OR species_listing_id IS NULL)
              AND change_types.name = 'DELETION' THEN -1
            ELSE 0
          END AS cites_I,
          CASE
            WHEN species_listings.abbreviation = 'II' AND change_types.name = 'ADDITION' THEN 1
            WHEN (species_listings.abbreviation = 'II' OR species_listing_id IS NULL)
              AND change_types.name = 'DELETION' THEN -1
            ELSE 0
          END AS cites_II,
          CASE
            WHEN species_listings.abbreviation = 'III' AND change_types.name = 'ADDITION' THEN 1
            WHEN (species_listings.abbreviation = 'III' OR species_listing_id IS NULL)
              AND change_types.name = 'DELETION' AND
                (listing_distributions.id IS NULL OR NOT listing_distributions.is_party) THEN -1
            ELSE 0
          END AS cites_III
          FROM listing_changes
          INNER JOIN change_types ON change_type_id = change_types.id
            AND change_types.name IN ('ADDITION','DELETION')
          INNER JOIN  designations ON change_types.designation_id = designations.id
            AND designations.name = 'CITES'
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

CREATE OR REPLACE FUNCTION rebuild_explicit_cites_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      PERFORM rebuild_explicit_cites_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_explicit_cites_listing() IS '
Procedure to rebuild explicit CITES listing in taxon_concepts.
';
