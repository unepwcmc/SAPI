CREATE OR REPLACE FUNCTION rebuild_mviews() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_taxon_concepts_mview();
    PERFORM rebuild_listing_changes_mview();
  END;
  $$;

COMMENT ON FUNCTION rebuild_mviews() IS 'Procedure to rebuild materialized views in the database.';

CREATE OR REPLACE FUNCTION rebuild_touch_taxon_concepts() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    WITH max_timestamp AS (
      SELECT lc.taxon_concept_id, GREATEST(tc.updated_at, MAX(lc.updated_at)) AS updated_at
      FROM (
        SELECT * FROM cites_listing_changes_mview
        UNION
        SELECT * FROM eu_listing_changes_mview
        UNION
        SELECT * FROM cms_listing_changes_mview
      ) lc
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
    );
  END;
  $$;