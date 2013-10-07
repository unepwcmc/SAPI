CREATE OR REPLACE FUNCTION rebuild_eu_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_eu_listed_status_for_node(node_id);
    PERFORM rebuild_eu_not_listed_status_for_node(node_id);
    --PERFORM rebuild_eu_hash_annotation_symbols_for_node(node_id);
    PERFORM rebuild_explicit_eu_listing_for_node(node_id);
    PERFORM rebuild_ancestor_eu_listing_for_node(node_id);
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_eu_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    --PERFORM rebuild_eu_annotation_symbols_for_node(NULL);
    PERFORM rebuild_eu_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_eu_listing() IS 'Procedure to rebuild EU listing in taxon_concepts.';
