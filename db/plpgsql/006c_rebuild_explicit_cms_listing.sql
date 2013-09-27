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
          ARRAY[
            listing -> 'cms_I', listing -> 'cms_II',
            listing -> 'cms_not_listed'
          ]
        ) s WHERE s IS NOT NULL),
          '/'
        )
      ) AS listing
      FROM (
        SELECT taxon_concept_id,
        CASE 
          WHEN BOOL_OR(species_listing_name = 'I') 
          THEN hstore('cms_I', 'I') ELSE hstore('cms_I', NULL)
        END || 
        CASE
          WHEN BOOL_OR(species_listing_name = 'II') 
          THEN hstore('cms_II', 'II') ELSE hstore('cms_II', NULL)
        END AS listing
        FROM cms_listing_changes_mview
        WHERE change_type_name = 'ADDITION' AND is_current
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
