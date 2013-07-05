CREATE OR REPLACE FUNCTION rebuild_cites_listed_status_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      designation designations%ROWTYPE;
      ancestor_node_ids INTEGER[];
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CITES';
    IF NOT FOUND THEN
      RETURN;
    END IF;
    PERFORM rebuild_listing_status_for_designation_and_node(designation, node_id);

    IF node_id IS NOT NULL THEN
      ancestor_node_ids := ancestor_node_ids_for_node(node_id);
    END IF;

    -- set cites_show to true for all taxa except:
    -- implicitly listed subspecies
    -- hybrids
    -- excluded and not listed taxa
    UPDATE taxon_concepts SET listing = listing ||
    CASE
      WHEN name_status = 'H'
      THEN hstore('cites_show', 'f')
      WHEN (data->'rank_name' = 'SUBSPECIES'
      OR data->'rank_name' = 'ORDER'
      OR data->'rank_name' = 'CLASS'
      OR data->'rank_name' = 'PHYLUM'
      OR data->'rank_name' = 'KINGDOM')
      AND listing->'cites_status' = 'LISTED'
      AND (listing->'cites_status_original')::BOOLEAN = FALSE
      THEN hstore('cites_show', 'f')
      WHEN listing->'cites_status' = 'EXCLUDED'
      THEN hstore('cites_show', 't')
      WHEN listing->'cites_status' = 'DELETED'
        AND (listing->'not_really_deleted')::BOOLEAN = TRUE
      THEN hstore('cites_show', 't')
      WHEN listing->'cites_status' = 'DELETED'
        OR (listing->'cites_status')::VARCHAR IS NULL
      THEN hstore('cites_show', 'f')
      ELSE hstore('cites_show', 't')
    END
    WHERE taxonomy_id = designation.taxonomy_id AND
    CASE WHEN node_id IS NOT NULL THEN id IN (SELECT id FROM UNNEST(ancestor_node_ids)) ELSE TRUE END;

    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cites_listed_status() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      PERFORM rebuild_cites_listed_status_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_cites_listed_status() IS '
  Procedure to rebuild the cites status flags in taxon_concepts.listing.
  1. cites_status
    "LISTED" - explicit/implicit cites listing,
    "DELETED" - taxa previously listed and then deleted
    "EXCLUDED" - taxonomic exceptions
  2. cites_status_original
    TRUE - cites_status is explicit (original)
    FALSE - cites_status is implicit (inherited)
  3. cites_show
    TRUE - taxon should show up in the checklist
    FALSE
';
