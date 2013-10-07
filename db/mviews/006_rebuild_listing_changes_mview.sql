CREATE OR REPLACE FUNCTION rebuild_listing_changes_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    taxonomy taxonomies%ROWTYPE;
    designation designations%ROWTYPE;
    designations TEXT[];
    i INT;
    sql TEXT;
  BEGIN
    RAISE INFO 'Creating listing_changes_mview materialized view (tmp)';
    DROP TABLE IF EXISTS listing_changes_mview_tmp CASCADE;

    SELECT * INTO taxonomy FROM taxonomies WHERE name = 'CITES_EU';
    IF FOUND THEN
      PERFORM rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy);
      SELECT * INTO designation FROM designations WHERE name = 'CITES';
      IF FOUND THEN
        designations := ARRAY_APPEND(designations, 'CITES');
        PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation);
      END IF;
      SELECT * INTO designation FROM designations WHERE name = 'EU';
      IF FOUND THEN
        designations := ARRAY_APPEND(designations, 'EU');
        PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation);
      END IF;
    END IF;

    SELECT * INTO taxonomy FROM taxonomies WHERE name = 'CMS';
    IF FOUND THEN
      PERFORM rebuild_taxonomy_taxon_concepts_and_ancestors_mview(taxonomy);
      SELECT * INTO designation FROM designations WHERE name = 'CMS';
      IF FOUND THEN
        designations := ARRAY_APPEND(designations, 'CMS');
        PERFORM rebuild_designation_listing_changes_mview(taxonomy, designation);
      END IF;
    END IF;

    sql := 'CREATE TABLE listing_changes_mview_tmp AS ';
    FOR i IN 1..ARRAY_UPPER(designations, 1) LOOP
      designations[i] := 'SELECT * FROM ' || LOWER(designations[i]) || '_listing_changes_mview';
    END LOOP;

    sql := sql || ARRAY_TO_STRING(designations, ' UNION ');

    EXECUTE sql;


    RAISE INFO 'Creating indexes on listing changes materialized view (tmp)';
    CREATE INDEX ON listing_changes_mview_tmp (show_in_timeline, taxon_concept_id, designation_id);
    CREATE INDEX ON listing_changes_mview_tmp (show_in_downloads, taxon_concept_id, designation_id);
    CREATE INDEX ON listing_changes_mview_tmp (id, taxon_concept_id);
    CREATE INDEX ON listing_changes_mview_tmp (original_taxon_concept_id);
    CREATE INDEX ON listing_changes_mview_tmp (inclusion_taxon_concept_id);
    CREATE INDEX ON listing_changes_mview_tmp (is_current, designation_name, change_type_name); -- Species+ downloads

    RAISE INFO 'Swapping listing_changes_mview materialized view';
    DROP TABLE IF EXISTS listing_changes_mview CASCADE;
    ALTER TABLE listing_changes_mview_tmp RENAME TO listing_changes_mview;

  END;
  $$;

COMMENT ON FUNCTION rebuild_listing_changes_mview() IS 'Procedure to rebuild listing changes materialized view in the database.';