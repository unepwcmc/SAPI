CREATE OR REPLACE FUNCTION rebuild_cms_listed_status_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    DECLARE
      designation designations%ROWTYPE;
    BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CMS';
    IF NOT FOUND THEN
      RETURN;
    END IF;

    PERFORM rebuild_listing_status_for_designation_and_node(designation, node_id);
    PERFORM set_cms_historically_listed_flag_for_node(node_id);
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cms_listed_status() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
      PERFORM rebuild_cms_listed_status_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_cms_listed_status() IS '
  Procedure to rebuild the CMS status flags in taxon_concepts.listing.
  1. cms_status
    "LISTED" - explicit/implicit cites listing,
    "DELETED" - taxa previously listed and then deleted
    "EXCLUDED" - taxonomic exceptions
  2. cms_status_original
    TRUE - cites_status is explicit (original)
    FALSE - cites_status is implicit (inherited)
';

CREATE OR REPLACE FUNCTION set_cms_historically_listed_flag_for_node(node_id integer)
  RETURNS VOID
  LANGUAGE sql
  AS $$
    WITH historical_listings_or_agreements AS (
      SELECT taxon_concept_id
      FROM listing_changes
      JOIN change_types
      ON change_types.id = change_type_id
      JOIN designations
      ON designations.id = designation_id AND designations.name = 'CMS'
      WHERE CASE WHEN $1 IS NULL THEN TRUE ELSE taxon_concept_id = $1 END

      UNION

      SELECT taxon_concept_id
      FROM taxon_instruments
      WHERE CASE WHEN $1 IS NULL THEN TRUE ELSE taxon_concept_id = $1 END
    ), historically_listed_taxa AS (
      SELECT taxon_concept_id AS id
      FROM historical_listings_or_agreements
      GROUP BY taxon_concept_id
    ), taxa_with_historically_listed_flag AS (
      SELECT taxon_concepts.id,
      CASE WHEN t.id IS NULL THEN FALSE ELSE TRUE END AS historically_listed
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id AND taxonomies.name = 'CMS'
      LEFT JOIN historically_listed_taxa t
      ON t.id = taxon_concepts.id
      WHERE CASE WHEN $1 IS NULL THEN TRUE ELSE taxon_concepts.id = $1 END
    )
    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) || HSTORE('cms_historically_listed', t.historically_listed::VARCHAR)
    FROM taxa_with_historically_listed_flag t
    WHERE t.id = taxon_concepts.id;
  $$;
