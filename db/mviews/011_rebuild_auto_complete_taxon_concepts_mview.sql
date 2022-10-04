CREATE OR REPLACE FUNCTION rebuild_auto_complete_taxon_concepts_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN

    DROP table IF EXISTS auto_complete_taxon_concepts_mview_tmp CASCADE;
    RAISE INFO 'Creating auto complete taxon concepts materialized view (tmp)';
    CREATE TABLE auto_complete_taxon_concepts_mview_tmp AS
    SELECT * FROM auto_complete_taxon_concepts_view;

    RAISE INFO 'Creating indexes on auto complete taxon concepts materialized view (tmp)';

    --this one used for Species+ autocomplete (both main and higher taxa in downloads)
    CREATE INDEX ON auto_complete_taxon_concepts_mview_tmp
    USING BTREE(name_for_matching text_pattern_ops, taxonomy_is_cites_eu, type_of_match, show_in_species_plus_ac);
    --this one used for Checklist autocomplete
    CREATE INDEX ON auto_complete_taxon_concepts_mview_tmp
    USING BTREE(name_for_matching text_pattern_ops, taxonomy_is_cites_eu, type_of_match, show_in_checklist_ac);
    --this one used for Trade autocomplete
    CREATE INDEX ON auto_complete_taxon_concepts_mview_tmp
    USING BTREE(name_for_matching text_pattern_ops, taxonomy_is_cites_eu, type_of_match, show_in_trade_ac);
    --this one used for Trade internal autocomplete
    CREATE INDEX ON auto_complete_taxon_concepts_mview_tmp
    USING BTREE(name_for_matching text_pattern_ops, taxonomy_is_cites_eu, type_of_match, show_in_trade_internal_ac);

    RAISE INFO 'Swapping auto complete taxon concepts materialized view';
    DROP table IF EXISTS auto_complete_taxon_concepts_mview CASCADE;
    ALTER TABLE auto_complete_taxon_concepts_mview_tmp RENAME TO auto_complete_taxon_concepts_mview;

  END;
  $$;

COMMENT ON FUNCTION rebuild_taxon_concepts_mview() IS 'Procedure to rebuild taxon concepts materialized view in the database.';
