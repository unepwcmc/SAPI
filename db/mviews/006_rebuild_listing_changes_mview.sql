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
    DROP TABLE IF EXISTS all_listing_changes_mview CASCADE;

    RAISE INFO 'Creating listing_changes_mview materialized view';
    DROP TABLE IF EXISTS listing_changes_mview CASCADE;

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

    sql := 'CREATE TABLE listing_changes_mview AS ';
    FOR i IN 1..ARRAY_UPPER(designations, 1) LOOP
      designations[i] := 'SELECT * FROM ' || LOWER(designations[i]) || '_listing_changes_mview';
    END LOOP;

    sql := sql || ARRAY_TO_STRING(designations, ' UNION ');
    RAISE INFO '%', sql;

    EXECUTE sql;


    RAISE INFO 'Creating indexes on listing changes materialized view';
    CREATE INDEX ON listing_changes_mview (show_in_timeline, taxon_concept_id, designation_id);
    CREATE INDEX ON listing_changes_mview (show_in_downloads, taxon_concept_id, designation_id);
    CREATE INDEX ON listing_changes_mview (id, taxon_concept_id);
    CREATE INDEX ON listing_changes_mview (original_taxon_concept_id);
    CREATE INDEX ON listing_changes_mview (inclusion_taxon_concept_id);
    CREATE INDEX ON listing_changes_mview (is_current, designation_name, change_type_name); -- Species+ downloads

    PERFORM rebuild_cites_species_listing_mview();
    PERFORM rebuild_eu_species_listing_mview();
    PERFORM rebuild_cms_species_listing_mview();

  END;
  $$;

COMMENT ON FUNCTION rebuild_listing_changes_mview() IS 'Procedure to rebuild listing changes materialized view in the database.';