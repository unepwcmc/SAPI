CREATE OR REPLACE FUNCTION rebuild_cites_eu_taxon_concepts_and_ancestors_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
  BEGIN
    SELECT * INTO taxonomy FROM taxonomies WHERE name = 'CITES_EU';
    IF FOUND THEN
      PERFORM rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy);
    END IF;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cms_taxon_concepts_and_ancestors_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
  BEGIN
    SELECT * INTO taxonomy FROM taxonomies WHERE name = 'CMS';
    IF FOUND THEN
      PERFORM rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy);
    END IF;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cites_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
    designation designations%ROWTYPE;
  BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CITES';
    IF FOUND THEN
      SELECT * INTO taxonomy FROM taxonomies WHERE id = designation.taxonomy_id;
      PERFORM rebuild_designation_all_listing_changes_mview(
        taxonomy, designation, NULL, NULL
      );
      PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation, NULL, NULL);
    END IF;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_eu_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
    designation designations%ROWTYPE;
    eu_interval RECORD;
    mviews TEXT[];
    sql TEXT;
    tmp_listing_changes_mview TEXT;
    listing_changes_mview TEXT;
  BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'EU';
    IF FOUND THEN
      SELECT * INTO taxonomy FROM taxonomies WHERE id = designation.taxonomy_id;
      FOR eu_interval IN (SELECT * FROM eu_regulations_applicability_view) LOOP
        SELECT ARRAY_APPEND(mviews, 'SELECT * FROM ' || listing_changes_mview_name(NULL, designation.name, eu_interval.start_date, eu_interval.end_date)) INTO mviews;
        PERFORM rebuild_designation_all_listing_changes_mview(
          taxonomy, designation, eu_interval.start_date, eu_interval.end_date
        );
        PERFORM rebuild_designation_listing_changes_mview(
          taxonomy, designation, eu_interval.start_date, eu_interval.end_date
        );
      END LOOP;
      SELECT listing_changes_mview_name('tmp_cascaded', designation.name, NULL, NULL)
      INTO tmp_listing_changes_mview;
      SELECT listing_changes_mview_name(NULL, designation.name, NULL, NULL)
      INTO listing_changes_mview;
      IF ARRAY_UPPER(mviews, 1) IS NULL THEN
        RETURN;
      END IF;
      SELECT 'CREATE TABLE ' || tmp_listing_changes_mview || ' AS ' || ARRAY_TO_STRING(mviews, ' UNION ') INTO sql;
      EXECUTE sql;
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (inclusion_taxon_concept_id)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (taxon_concept_id, original_taxon_concept_id, change_type_id, effective_at)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (show_in_timeline, taxon_concept_id)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (show_in_downloads, taxon_concept_id)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (original_taxon_concept_id)';
      EXECUTE 'CREATE INDEX ON ' || tmp_listing_changes_mview || ' (is_current, change_type_name)'; -- Species+ downloads

      RAISE INFO 'Swapping eu_listing_changes materialized view';
      EXECUTE 'DROP TABLE IF EXISTS ' || listing_changes_mview || ' CASCADE';
      EXECUTE 'ALTER TABLE ' || tmp_listing_changes_mview || ' RENAME TO ' || listing_changes_mview;
    END IF;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cms_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
    designation designations%ROWTYPE;
  BEGIN
    SELECT * INTO designation FROM designations WHERE name = 'CMS';
    IF FOUND THEN
      SELECT * INTO taxonomy FROM taxonomies WHERE id = designation.taxonomy_id;
      PERFORM rebuild_designation_all_listing_changes_mview(
        taxonomy, designation, NULL, NULL
      );
      PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation, NULL, NULL);
    END IF;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_cites_eu_taxon_concepts_and_ancestors_mview();
    PERFORM rebuild_cms_taxon_concepts_and_ancestors_mview();
    PERFORM rebuild_cites_listing_changes_mview();
    PERFORM rebuild_eu_listing_changes_mview();
    PERFORM rebuild_cms_listing_changes_mview();
  END;
  $$;

COMMENT ON FUNCTION rebuild_listing_changes_mview() IS 'Procedure to rebuild listing changes materialized view in the database.';