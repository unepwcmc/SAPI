
-- NOTE: rebuild_taxon_concepts_mview duplicates rebuild_auto_complete_taxon_concepts_mview
-- so they have been moved into the same file.

CREATE OR REPLACE FUNCTION rebuild_auto_complete_taxon_concepts_mview()
  RETURNS void
  LANGUAGE plpgsql
  AS $FUNCTION$
  BEGIN
    DROP TABLE IF EXISTS auto_complete_taxon_concepts_mview_tmp CASCADE;

    RAISE INFO 'Creating auto complete taxon concepts materialized view (tmp)';

    CREATE TABLE auto_complete_taxon_concepts_mview_tmp AS
    SELECT * FROM auto_complete_taxon_concepts_view;

    RAISE INFO 'Creating indexes on auto complete taxon concepts materialized view (tmp)';

    CREATE INDEX idx_ac_taxon_gist_tmp ON auto_complete_taxon_concepts_mview_tmp
      USING GIST(name_for_matching gist_trgm_ops);

    -- For Species+ autocomplete (both main and higher taxa in downloads)
    CREATE INDEX idx_ac_taxon_splus_btree_tmp ON auto_complete_taxon_concepts_mview_tmp
      USING BTREE(name_for_matching text_pattern_ops, taxonomy_is_cites_eu, type_of_match)
      WHERE show_in_species_plus_ac;

    -- For Species+ autocomplete (both main and higher taxa in downloads), GIST trigrams
    CREATE INDEX idx_ac_taxon_splus_gist_tmp ON auto_complete_taxon_concepts_mview_tmp
      USING GIST(name_for_matching gist_trgm_ops)
      WHERE show_in_species_plus_ac;

    -- For Checklist autocomplete
    CREATE INDEX idx_ac_taxon_checklist_btree_tmp ON auto_complete_taxon_concepts_mview_tmp
      USING BTREE(name_for_matching text_pattern_ops, type_of_match)
      WHERE taxonomy_is_cites_eu AND show_in_checklist_ac;

    -- For Checklist autocomplete, GIST trigrams
    CREATE INDEX idx_ac_taxon_checklist_gist_tmp ON auto_complete_taxon_concepts_mview_tmp
      USING GIST(name_for_matching gist_trgm_ops) WHERE taxonomy_is_cites_eu AND show_in_checklist_ac;

    -- For Trade autocomplete
    CREATE INDEX idx_ac_taxon_trade_ac_btree_tmp ON auto_complete_taxon_concepts_mview_tmp
      USING BTREE(name_for_matching text_pattern_ops, type_of_match, taxonomy_is_cites_eu)
      WHERE show_in_trade_ac;

    -- For Trade autocomplete, GIST trigrams
    CREATE INDEX idx_ac_taxon_trade_ac_gist_tmp ON auto_complete_taxon_concepts_mview_tmp
      USING GIST(name_for_matching gist_trgm_ops)
      WHERE show_in_trade_ac;

    -- For Trade internal autocomplete
    CREATE INDEX idx_ac_taxon_trade_internal_btree_tmp ON auto_complete_taxon_concepts_mview_tmp
      USING BTREE(name_for_matching text_pattern_ops, type_of_match, taxonomy_is_cites_eu)
      WHERE show_in_trade_internal_ac;

    -- For Trade internal autocomplete, GIST trigrams
    CREATE INDEX idx_ac_taxon_trade_internal_gist_tmp ON auto_complete_taxon_concepts_mview_tmp
      USING GIST(name_for_matching gist_trgm_ops)
      WHERE show_in_trade_internal_ac;

    RAISE INFO 'Swapping auto complete taxon concepts materialized view';

    DROP TABLE IF EXISTS auto_complete_taxon_concepts_mview CASCADE;

    ALTER TABLE auto_complete_taxon_concepts_mview_tmp RENAME TO auto_complete_taxon_concepts_mview;

    ALTER INDEX idx_ac_taxon_gist_tmp                 RENAME TO idx_ac_taxon_gist;
    ALTER INDEX idx_ac_taxon_splus_btree_tmp          RENAME TO idx_ac_taxon_splus_btree;
    ALTER INDEX idx_ac_taxon_splus_gist_tmp           RENAME TO idx_ac_taxon_splus_gist;
    ALTER INDEX idx_ac_taxon_checklist_btree_tmp      RENAME TO idx_ac_taxon_checklist_btree;
    ALTER INDEX idx_ac_taxon_checklist_gist_tmp       RENAME TO idx_ac_taxon_checklist_gist;
    ALTER INDEX idx_ac_taxon_trade_ac_btree_tmp       RENAME TO idx_ac_taxon_trade_ac_btree;
    ALTER INDEX idx_ac_taxon_trade_ac_gist_tmp        RENAME TO idx_ac_taxon_trade_ac_gist;
    ALTER INDEX idx_ac_taxon_trade_internal_btree_tmp RENAME TO idx_ac_taxon_trade_internal_btree;
    ALTER INDEX idx_ac_taxon_trade_internal_gist_tmp  RENAME TO idx_ac_taxon_trade_internal_gist;
  END;
  $FUNCTION$;

COMMENT ON FUNCTION rebuild_auto_complete_taxon_concepts_mview() IS 'Procedure to rebuild taxon concept autocomplete table in the database.';

CREATE OR REPLACE FUNCTION rebuild_taxon_concepts_mview() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    DROP TABLE IF EXISTS taxon_concepts_mview_tmp CASCADE;

    RAISE INFO 'Creating taxon concepts materialized view (tmp)';
    CREATE TABLE taxon_concepts_mview_tmp AS
    SELECT *,
      FALSE AS dirty,
      NULL::TIMESTAMP WITH TIME ZONE AS expiry
    FROM taxon_concepts_view;

    RAISE INFO 'Creating indexes on taxon concepts materialized view (tmp)';
    CREATE INDEX idx_mtaxon_id_tmp               ON taxon_concepts_mview_tmp (id);
    CREATE INDEX idx_mtaxon_parent_id_tmp        ON taxon_concepts_mview_tmp (parent_id);
    CREATE INDEX idx_mtaxon_kingdom_position_tmp ON taxon_concepts_mview_tmp (taxonomy_is_cites_eu, cites_listed, kingdom_position);
    CREATE INDEX idx_mtaxon_cms_csv_tmp          ON taxon_concepts_mview_tmp (cms_show, name_status, cms_listing_original, taxonomy_is_cites_eu, rank_name); -- cms csv download
    CREATE INDEX idx_mtaxon_cites_csv_tmp        ON taxon_concepts_mview_tmp (cites_show, name_status, cites_listing_original, taxonomy_is_cites_eu, rank_name); -- cites csv download
    CREATE INDEX idx_mtaxon_eu_csv_tmp           ON taxon_concepts_mview_tmp (eu_show, name_status, eu_listing_original, taxonomy_is_cites_eu, rank_name); -- eu csv download
    CREATE INDEX idx_mtaxon_id_countries_ids_tmp ON taxon_concepts_mview_tmp USING GIN (countries_ids_ary);

    RAISE INFO 'Swapping taxon concepts materialized view';

    DROP TABLE IF EXISTS taxon_concepts_mview CASCADE;
    ALTER TABLE taxon_concepts_mview_tmp RENAME TO taxon_concepts_mview;

    ALTER INDEX idx_mtaxon_id_tmp               RENAME TO idx_mtaxon_id;
    ALTER INDEX idx_mtaxon_parent_id_tmp        RENAME TO idx_mtaxon_parent_id;
    ALTER INDEX idx_mtaxon_kingdom_position_tmp RENAME TO idx_mtaxon_kingdom_position;
    ALTER INDEX idx_mtaxon_cms_csv_tmp          RENAME TO idx_mtaxon_cms_csv;
    ALTER INDEX idx_mtaxon_cites_csv_tmp        RENAME TO idx_mtaxon_cites_csv;
    ALTER INDEX idx_mtaxon_eu_csv_tmp           RENAME TO idx_mtaxon_eu_csv;
    ALTER INDEX idx_mtaxon_id_countries_ids_tmp RENAME TO idx_mtaxon_id_countries_ids;

    PERFORM rebuild_auto_complete_taxon_concepts_mview();
  END;
  $$;

COMMENT ON FUNCTION rebuild_taxon_concepts_mview() IS 'Procedure to rebuild taxon concepts managed table in the database.';
