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
          ARRAY[
            listing -> 'eu_A', listing -> 'eu_B', listing -> 'eu_C',
            listing -> 'eu_D', listing -> 'eu_not_listed'
          ]
        ) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM (
        SELECT taxon_concept_id,
        CASE 
          WHEN BOOL_OR(species_listing_name = 'A') 
          THEN hstore('eu_A', 'A') ELSE hstore('eu_A', NULL)
        END || 
        CASE 
          WHEN BOOL_OR(species_listing_name = 'B') 
          THEN hstore('eu_B', 'B') ELSE hstore('eu_B', NULL)
        END || 
        CASE 
          WHEN BOOL_OR(species_listing_name = 'C') 
          THEN hstore('eu_C', 'C') ELSE hstore('eu_C', NULL)
        END || 
        CASE
          WHEN BOOL_OR(species_listing_name = 'D') 
          THEN hstore('eu_D', 'D') ELSE hstore('eu_D', NULL)
        END AS listing
        FROM eu_listing_changes_mview
        WHERE change_type_name = 'ADDITION' AND is_current
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
