CREATE OR REPLACE FUNCTION rebuild_cms_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_cms_listed_status_for_node(node_id);
    PERFORM rebuild_cms_not_listed_status_for_node(node_id);
    PERFORM rebuild_explicit_cms_listing_for_node(node_id);
    PERFORM rebuild_ancestor_cms_listing_for_node(node_id);
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cms_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_cms_listing_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_cms_listing() IS 'Procedure to rebuild CMS listing in taxon_concepts.';
