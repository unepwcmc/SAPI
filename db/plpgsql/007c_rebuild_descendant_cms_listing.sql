CREATE OR REPLACE FUNCTION rebuild_descendant_cms_listing_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CMS';
    PERFORM rebuild_descendant_listing_for_designation_and_node(designation, node_id);
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_descendant_cms_listing() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      PERFORM rebuild_descendant_cms_listing_for_node(NULL);
    END;
  $$;


COMMENT ON FUNCTION rebuild_descendant_cms_listing() IS 'Procedure to rebuild CMS descendant listings in taxon_concepts.';
