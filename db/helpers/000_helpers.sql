CREATE OR REPLACE FUNCTION array_intersect(anyarray, anyarray)
  RETURNS anyarray
  language SQL
AS $FUNCTION$
    SELECT ARRAY(
        SELECT UNNEST($1)
        INTERSECT
        SELECT UNNEST($2)
    );
$FUNCTION$;

CREATE OR REPLACE FUNCTION squish_null(TEXT) RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT CASE WHEN SQUISH($1) = '' THEN NULL ELSE SQUISH($1) END;
  $$;

COMMENT ON FUNCTION squish_null(TEXT) IS
  'Squishes whitespace characters in a string and returns null for empty string';

CREATE OR REPLACE FUNCTION full_name_with_spp(rank_name VARCHAR(255), full_name VARCHAR(255)) RETURNS VARCHAR(255)
  LANGUAGE sql IMMUTABLE
  AS $$
    SELECT CASE
      WHEN $1 IN ('ORDER', 'FAMILY', 'SUBFAMILY', 'GENUS')
      THEN $2 || ' spp.'
      ELSE $2
    END;
  $$;

COMMENT ON FUNCTION full_name_with_spp(rank_name VARCHAR(255), full_name VARCHAR(255)) IS
  'Returns full name with ssp where applicable depending on rank.';

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


CREATE OR REPLACE FUNCTION drop_trade_sandboxes() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    current_table_name TEXT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'trade_sandbox%'
      AND table_name != 'trade_sandbox_template'
      AND table_type != 'VIEW'
    LOOP
      EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;

COMMENT ON FUNCTION drop_trade_sandboxes() IS '
Drops all trade_sandbox_n tables. Used in specs only, you need to know what
you''re doing. If you''re looking to drop all sandboxes in the live system,
use the rake db:drop_sandboxes task instead.';

CREATE OR REPLACE FUNCTION drop_trade_sandbox_views() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    current_view_name TEXT;
  BEGIN
    FOR current_view_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'trade_sandbox%_view'
      AND table_type = 'VIEW'
    LOOP
      EXECUTE 'DROP VIEW IF EXISTS ' || current_view_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;

CREATE OR REPLACE FUNCTION create_trade_sandbox_views() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    current_table_name TEXT;
    aru_id INT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'trade_sandbox%'
      AND table_name != 'trade_sandbox_template'
      AND table_type != 'VIEW'
    LOOP
      aru_id := SUBSTRING(current_table_name, E'trade_sandbox_(\\d+)')::INT;
      IF aru_id IS NULL THEN
  RAISE WARNING 'Unable to determine annual report upload id from %', current_table_name;
      ELSE
  PERFORM create_trade_sandbox_view(current_table_name, aru_id);
      END IF;
    END LOOP;
    RETURN;
  END;
  $$;

CREATE OR REPLACE FUNCTION refresh_trade_sandbox_views() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM drop_trade_sandbox_views();
    PERFORM create_trade_sandbox_views();
    RETURN;
  END;
  $$;

COMMENT ON FUNCTION refresh_trade_sandbox_views() IS '
Drops all trade_sandbox_n_view views and creates them again. Useful when the
view definition has changed and has to be applied to existing views.';


CREATE OR REPLACE FUNCTION create_trade_sandbox_view(
  target_table_name TEXT, idx INT
  ) RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    execute 'CREATE VIEW ' || target_table_name || '_view AS
      SELECT aru.point_of_view,
      CASE
        WHEN aru.point_of_view = ''E''
        THEN geo_entities.iso_code2
        ELSE trading_partner
      END AS exporter,
      CASE
        WHEN aru.point_of_view = ''E''
        THEN trading_partner
        ELSE geo_entities.iso_code2 
      END AS importer,
      taxon_concepts.full_name AS accepted_taxon_name,
      taxon_concepts.data->''rank_name'' AS rank,
      taxon_concepts.rank_id,
      ' || target_table_name || '.*
      FROM ' || target_table_name || '
      JOIN trade_annual_report_uploads aru ON aru.id = ' || idx || '
      JOIN geo_entities ON geo_entities.id = aru.trading_country_id
      LEFT JOIN taxon_concepts ON taxon_concept_id = taxon_concepts.id';
    RETURN;
  END;
  $$;

CREATE OR REPLACE FUNCTION drop_eu_lc_mviews() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    current_table_name TEXT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE 'eu_%_listing_changes_mview'
      AND table_type != 'VIEW'
    LOOP
      EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;

CREATE OR REPLACE FUNCTION drop_import_tables() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    current_table_name TEXT;
  BEGIN
    FOR current_table_name IN SELECT table_name FROM information_schema.tables
    WHERE table_name LIKE '%_import'
      AND table_type != 'VIEW'
    LOOP
      EXECUTE 'DROP TABLE ' || current_table_name || ' CASCADE';
    END LOOP;
    RETURN;
  END;
  $$;

CREATE OR REPLACE FUNCTION listing_changes_mview_name(prefix TEXT, designation TEXT, events_ids INT[])
  RETURNS TEXT
  LANGUAGE SQL IMMUTABLE
  AS $$
    SELECT CASE WHEN $1 IS NULL THEN '' ELSE $1 || '_' END ||
    $2 ||
    CASE
      WHEN $3 IS NOT NULL
      THEN '_' || ARRAY_TO_STRING($3, '_')
      ELSE ''
    END || '_listing_changes_mview';
  $$;
