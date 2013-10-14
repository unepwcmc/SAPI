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
          ARRAY[
            listing -> 'cites_I', listing -> 'cites_II', listing -> 'cites_III',
            listing -> 'cites_not_listed'
          ]
        ) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM (
        SELECT taxon_concept_id, 
        CASE 
          WHEN BOOL_OR(species_listing_name = 'I') 
          THEN hstore('cites_I', 'I') ELSE hstore('cites_I', NULL)
        END || 
        CASE
          WHEN BOOL_OR(species_listing_name = 'II') 
          THEN hstore('cites_II', 'II') ELSE hstore('cites_II', NULL)
        END ||
        CASE
          WHEN BOOL_OR(species_listing_name = 'III') 
          THEN hstore('cites_III', 'III') ELSE hstore('cites_III', NULL)
        END AS listing
        FROM cites_listing_changes_mview
        WHERE change_type_name = 'ADDITION' AND is_current
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
