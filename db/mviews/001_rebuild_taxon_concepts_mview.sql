CREATE OR REPLACE FUNCTION rebuild_taxon_concepts_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP table IF EXISTS taxon_concepts_mview_tmp CASCADE;

    RAISE INFO 'Creating taxon concepts materialized view (tmp)';
    CREATE TABLE taxon_concepts_mview_tmp AS
    SELECT *,
    false as dirty,
    null::timestamp with time zone as expiry
    FROM taxon_concepts_view;

    RAISE INFO 'Creating indexes on taxon concepts materialized view (tmp)';
    CREATE INDEX ON taxon_concepts_mview_tmp (id);
    CREATE INDEX ON taxon_concepts_mview_tmp (parent_id);
    CREATE INDEX ON taxon_concepts_mview_tmp (taxonomy_is_cites_eu, cites_listed, kingdom_position);
    CREATE INDEX ON taxon_concepts_mview_tmp (cms_show, name_status, cms_listing_original, taxonomy_is_cites_eu, rank_name); -- cms csv download
    CREATE INDEX ON taxon_concepts_mview_tmp (cites_show, name_status, cites_listing_original, taxonomy_is_cites_eu, rank_name); -- cites csv download
    CREATE INDEX ON taxon_concepts_mview_tmp (eu_show, name_status, eu_listing_original, taxonomy_is_cites_eu, rank_name); -- eu csv download
    CREATE INDEX ON taxon_concepts_mview_tmp USING GIN (countries_ids_ary);

    RAISE INFO 'Swapping taxon concepts materialized view';
    DROP table IF EXISTS taxon_concepts_mview CASCADE;
    ALTER TABLE taxon_concepts_mview_tmp RENAME TO taxon_concepts_mview;

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
