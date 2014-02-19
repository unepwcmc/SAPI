CREATE OR REPLACE FUNCTION rebuild_mviews() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_taxon_concepts_mview();
    PERFORM rebuild_listing_changes_mview();
  END;
  $$;

COMMENT ON FUNCTION rebuild_mviews() IS 'Procedure to rebuild materialized views in the database.';

CREATE OR REPLACE FUNCTION rebuild_touch_cites_taxon_concepts() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_touch_designation_taxon_concepts('CITES');
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_touch_eu_taxon_concepts() RETURNS void

DROP FUNCTION IF EXISTS ancestor_listing_auto_note(rank_name VARCHAR(255), full_name VARCHAR(255), change_type_name VARCHAR(255));

CREATE OR REPLACE FUNCTION ancestor_listing_auto_note(taxon_concept taxon_concepts, listing_change listing_changes, locale CHAR(2))
RETURNS TEXT
  LANGUAGE plpgsql STRICT
  AS $$
  DECLARE
    result TEXT;
  BEGIN
    IF NOT ARRAY[LOWER(locale)] && ARRAY['en', 'es', 'fr'] THEN
      locale := 'en';
    END IF;
    EXECUTE 'SELECT
      UPPER(COALESCE(
        ranks.display_name_' || locale || ',
        ranks.display_name_en,
        ranks.name
      )) || '' '' ||
      COALESCE(
        change_types.display_name_' || locale || ',
        change_types.display_name_en,
        change_types.name
      ) || '' '' ||
      full_name_with_spp(ranks.name, ''' || taxon_concept.full_name || ''')
      FROM ranks, change_types
      WHERE ranks.id = ' || taxon_concept.rank_id || '
      AND change_types.id = ' || listing_change.change_type_id
    INTO result;
    RETURN result;
  END;
  $$;

CREATE OR REPLACE FUNCTION ancestor_listing_auto_note_en(taxon_concepts, listing_changes)
RETURNS TEXT
  LANGUAGE sql IMMUTABLE
  AS $$
    SELECT * FROM ancestor_listing_auto_note($1, $2, 'en');
  $$;

COMMENT ON FUNCTION ancestor_listing_auto_note_en(taxon_concepts, listing_changes) IS
  'Returns English auto note (used for inherited listing changes).';

CREATE OR REPLACE FUNCTION ancestor_listing_auto_note_es(taxon_concepts, listing_changes)
RETURNS TEXT
  LANGUAGE sql IMMUTABLE
  AS $$
    SELECT * FROM ancestor_listing_auto_note($1, $2, 'es');
  $$;

COMMENT ON FUNCTION ancestor_listing_auto_note_es(taxon_concepts, listing_changes) IS
  'Returns Spanish auto note (used for inherited listing changes).';

CREATE OR REPLACE FUNCTION ancestor_listing_auto_note_fr(taxon_concepts, listing_changes)
RETURNS TEXT
  LANGUAGE sql IMMUTABLE
  AS $$
    SELECT * FROM ancestor_listing_auto_note($1, $2, 'fr');
  $$;

COMMENT ON FUNCTION ancestor_listing_auto_note_fr(taxon_concepts, listing_changes) IS
  'Returns French auto note (used for inherited listing changes).';

CREATE OR REPLACE FUNCTION rebuild_mviews() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_touch_designation_taxon_concepts('EU');
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_touch_cms_taxon_concepts() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_touch_designation_taxon_concepts('CMS');
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_touch_designation_taxon_concepts(designation_name TEXT) RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    sql TEXT;
  BEGIN
    sql := 'WITH max_timestamp AS (
      SELECT lc.taxon_concept_id, GREATEST(tc.updated_at, MAX(lc.updated_at)) AS updated_at
      FROM ' || designation_name || '_listing_changes_mview lc
      JOIN taxon_concepts_mview tc
      ON lc.taxon_concept_id = tc.id
      GROUP BY taxon_concept_id, tc.updated_at
    )
    UPDATE taxon_concepts
    SET touched_at = max_timestamp.updated_at
    FROM max_timestamp
    WHERE max_timestamp.taxon_concept_id = taxon_concepts.id
    AND (
      taxon_concepts.touched_at < max_timestamp.updated_at
      OR taxon_concepts.touched_at IS NULL
    );';
    EXECUTE sql;
  END;
  $$;
