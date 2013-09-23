CREATE OR REPLACE FUNCTION rebuild_cms_not_listed_status_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CMS';
    IF NOT FOUND THEN
      RETURN;
    END IF;
    PERFORM rebuild_not_listed_status_for_designation_and_node(designation, node_id);
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cms_not_listed_status() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      PERFORM rebuild_cms_not_listed_status_for_node(NULL);
    END;
  $$;


COMMENT ON FUNCTION rebuild_cms_not_listed_status() IS '
  Procedure to rebuild the cms_fully_covered AND cms_not_listed flags in taxon_concepts.listing.
  1. cms_fully_covered
    TRUE - all descendants are listed,
    FALSE - some descendants were excluded or deleted from listing
  2. cms_not_listed
    NC - either this taxon or some of its descendants were excluded or deleted from listing
';
