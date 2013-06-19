CREATE OR REPLACE FUNCTION rebuild_eu_listed_status_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'EU';
    PERFORM rebuild_listing_status_for_designation_and_node(designation, node_id);
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_eu_listed_status() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      PERFORM rebuild_eu_listed_status_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_eu_listed_status() IS '
  Procedure to rebuild the eu status flags in taxon_concepts.listing.
  1. eu_status
    "LISTED" - explicit/implicit cites listing,
    "DELETED" - taxa previously listed and then deleted
    "EXCLUDED" - taxonomic exceptions
  2. eu_status_original
    TRUE - cites_status is explicit (original)
    FALSE - cites_status is implicit (inherited)
  3. listing_updated_at
    the date listing was last updated for this taxon (explicitly or explicitly)
';
