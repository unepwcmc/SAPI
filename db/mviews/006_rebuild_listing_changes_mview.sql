CREATE OR REPLACE FUNCTION rebuild_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
    designation designations%ROWTYPE;
  BEGIN
    RAISE NOTICE 'Creating listing_changes_mview materialized view';
    EXECUTE 'DROP TABLE IF EXISTS listing_changes_mview CASCADE';

    SELECT * INTO taxonomy FROM taxonomies WHERE name = 'CITES_EU';
    PERFORM rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy);
    SELECT * INTO designation FROM designations WHERE name = 'CITES';
    PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation);
    SELECT * INTO designation FROM designations WHERE name = 'EU';
    PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation);

    SELECT * INTO taxonomy FROM taxonomies WHERE name = 'CMS';
    PERFORM rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy);
    SELECT * INTO designation FROM designations WHERE name = 'CMS';
    PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation);

    CREATE TABLE listing_changes_mview AS
    SELECT  *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM (
      SELECT * FROM cites_listing_changes_mview
      UNION
      SELECT * FROM eu_listing_changes_mview
      UNION
      SELECT * FROM cms_listing_changes_mview
    ) designation_lc;

    RAISE NOTICE 'Creating indexes on listing changes materialized view';
    CREATE INDEX ON listing_changes_mview (show_in_timeline, taxon_concept_id, designation_id);
    CREATE INDEX ON listing_changes_mview (show_in_downloads, taxon_concept_id, designation_id);
    CREATE INDEX ON listing_changes_mview (id, taxon_concept_id);
    CREATE INDEX ON listing_changes_mview (original_taxon_concept_id);
    CREATE INDEX ON listing_changes_mview (inclusion_taxon_concept_id);

  END;
  $$;

COMMENT ON FUNCTION rebuild_listing_changes_mview() IS 'Procedure to rebuild listing changes materialized view in the database.';