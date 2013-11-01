CREATE OR REPLACE FUNCTION rebuild_cites_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_cites_listed_status_for_node(node_id);
    PERFORM rebuild_cites_not_listed_status_for_node(node_id);
    PERFORM rebuild_cites_hash_annotation_symbols_for_node(node_id);
    PERFORM rebuild_explicit_cites_listing_for_node(node_id);
    PERFORM rebuild_ancestor_cites_listing_for_node(node_id);
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cites_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_cites_annotation_symbols_for_node(NULL);
    PERFORM rebuild_cites_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_cites_listing() IS 'Procedure to rebuild CITES listing in taxon_concepts.';
