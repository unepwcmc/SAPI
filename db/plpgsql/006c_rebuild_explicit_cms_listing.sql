CREATE OR REPLACE FUNCTION rebuild_explicit_cms_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    UPDATE taxon_concepts SET listing =
    CASE
    WHEN NOT (taxon_concepts.listing->'cms_status_original')::BOOLEAN
    THEN taxon_concepts.listing - ARRAY['cms_not_listed']
    ELSE taxon_concepts.listing
    END || qqq.listing
    FROM (
      SELECT taxon_concept_id, listing ||
      hstore('cms_listing_original', ARRAY_TO_STRING(
        -- unnest to filter out the nulls
        ARRAY(SELECT * FROM UNNEST(
          ARRAY[listing -> 'cms_I', listing -> 'cms_II']) s
          WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM (
        SELECT taxon_concept_id,
          hstore('cms_I', CASE WHEN SUM(cms_I) > 0 THEN 'I' ELSE NULL END) ||
          hstore('cms_II', CASE WHEN SUM(cms_II) > 0 THEN 'II' ELSE NULL END)
          AS listing
        FROM (
          SELECT taxon_concept_id, effective_at, species_listings.abbreviation, change_types.name AS change_type,
          CASE
            WHEN species_listings.abbreviation = 'I' AND change_types.name = 'ADDITION' THEN 1
            WHEN (species_listings.abbreviation = 'I' OR species_listing_id IS NULL)
              AND change_types.name = 'DELETION' THEN -1
            ELSE 0
          END AS cms_I,
          CASE
            WHEN species_listings.abbreviation = 'II' AND change_types.name = 'ADDITION' THEN 1
            WHEN (species_listings.abbreviation = 'II' OR species_listing_id IS NULL)
              AND change_types.name = 'DELETION' THEN -1
            ELSE 0
          END AS cms_II
          FROM listing_changes
          INNER JOIN change_types ON change_type_id = change_types.id
            AND change_types.name IN ('ADDITION','DELETION')
          INNER JOIN  designations ON change_types.designation_id = designations.id
            AND designations.name = 'CMS'
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

CREATE OR REPLACE FUNCTION rebuild_explicit_cms_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_explicit_cms_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_explicit_cms_listing() IS '
Procedure to rebuild explicit CMS listing in taxon_concepts.
';
