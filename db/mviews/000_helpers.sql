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
      SELECT lc.taxon_concept_id, GREATEST(tc.updated_at, MAX(lc.updated_at), tc.dependents_updated_at) AS updated_at
      FROM ' || designation_name || '_listing_changes_mview lc
      JOIN taxon_concepts_mview tc
      ON lc.taxon_concept_id = tc.id
      GROUP BY taxon_concept_id, tc.updated_at, tc.dependents_updated_at
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
