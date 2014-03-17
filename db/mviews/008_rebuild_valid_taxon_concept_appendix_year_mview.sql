DROP FUNCTION IF EXISTS rebuild_valid_species_name_annex_year_mview();
CREATE OR REPLACE FUNCTION rebuild_valid_taxon_concept_annex_year_mview() RETURNS VOID
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_valid_taxon_concept_appendix_year_designation_mview('EU');
  END;
$$;

DROP FUNCTION IF EXISTS rebuild_valid_species_name_appendix_year_mview();
CREATE OR REPLACE FUNCTION rebuild_valid_taxon_concept_appendix_year_mview() RETURNS VOID
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_valid_taxon_concept_appendix_year_designation_mview('CITES');
  END;
$$;

DROP FUNCTION IF EXISTS rebuild_valid_species_name_appendix_year_designation_mview(
  designation_name TEXT
  );
CREATE OR REPLACE FUNCTION rebuild_valid_taxon_concept_appendix_year_designation_mview(
  designation_name TEXT
  ) RETURNS VOID
  LANGUAGE plpgsql
  AS $$
  DECLARE
    mview_name TEXT;
    appendix TEXT;
  BEGIN
    IF designation_name = 'EU' THEN
      appendix := 'annex';
    ELSE
      appendix := 'appendix';
    END IF;
    mview_name := 'valid_taxon_concept_' || appendix || '_year_mview';

    EXECUTE 'DROP TABLE IF EXISTS ' || designation_name || '_listing_changes_intervals_mview;';

    EXECUTE 'CREATE TEMP TABLE ' || designation_name || '_listing_changes_intervals_mview AS
    WITH additions_and_deletions AS (
      SELECT change_type_name, effective_at, species_listing_name, taxon_concept_id
      FROM ' || designation_name || '_listing_changes_mview
      WHERE change_type_name = ''ADDITION'' OR change_type_name = ''DELETION''
    ), additions AS (
      SELECT change_type_name, effective_at, species_listing_name, taxon_concept_id
      FROM additions_and_deletions
      WHERE change_type_name = ''ADDITION''
    )
    SELECT a.taxon_concept_id, a.species_listing_name,
    a.effective_at AS effective_from,
    MIN(ad.effective_at) AS effective_to
    FROM additions a
    LEFT JOIN additions_and_deletions ad
    ON a.taxon_concept_id = ad.taxon_concept_id
    AND a.effective_at < ad.effective_at
    GROUP BY a.taxon_concept_id, a.species_listing_name, a.effective_at
    ORDER BY taxon_concept_id, effective_from';

    EXECUTE 'DROP TABLE IF EXISTS tmp_' || mview_name || ';';

    EXECUTE 'CREATE TABLE tmp_' || mview_name || ' AS
    WITH RECURSIVE unmerged_intervals AS (
      SELECT
      taxon_concept_id, species_listing_name, effective_from, effective_to
      FROM ' || designation_name || '_listing_changes_intervals_mview

      UNION

      SELECT l.taxon_concept_id, l.species_listing_name, l.effective_from, r.effective_to
      FROM unmerged_intervals l
      JOIN ' || designation_name || '_listing_changes_intervals_mview r
      ON r.taxon_concept_id = l.taxon_concept_id
      AND r.species_listing_name = l.species_listing_name
      AND r.effective_from = l.effective_to
    ), left_merged_intervals AS (
      SELECT taxon_concept_id, species_listing_name, MIN(effective_from) AS effective_from, effective_to
      FROM unmerged_intervals
      GROUP BY taxon_concept_id, species_listing_name, effective_to
    ), merged_intervals AS (
      SELECT taxon_concept_id, species_listing_name, effective_from,
      CASE WHEN EVERY(effective_to IS NOT NULL) THEN MAX(effective_to) ELSE NULL END AS effective_to 
      FROM left_merged_intervals
      GROUP BY taxon_concept_id, species_listing_name, effective_from
    ), intervals AS (
      SELECT taxon_concept_id, species_listing_name AS ' || appendix || ', effective_from, effective_to
      FROM merged_intervals
      JOIN taxon_concepts
      ON taxon_concepts.id = merged_intervals.taxon_concept_id
      ORDER BY taxon_concept_id, ' || appendix || ', effective_from, effective_to
    ), hybrids AS (
      SELECT other_taxon_concept_id AS hybrid_id,
      taxon_concept_id
      FROM taxon_relationships rel
      JOIN taxon_relationship_types rel_type
      ON rel.taxon_relationship_type_id = rel_type.id AND rel_type.name = ''HAS_HYBRID''
    )
    SELECT * FROM intervals
    UNION
    SELECT hybrid_id, ' || appendix || ', effective_from, effective_to
    FROM hybrids
    JOIN intervals
    ON intervals.taxon_concept_id = hybrids.taxon_concept_id';

    EXECUTE 'CREATE INDEX ON tmp_' || mview_name || ' (taxon_concept_id, ' || appendix || ', effective_from, effective_to);';

    EXECUTE 'DROP TABLE IF EXISTS valid_species_name_' || appendix || '_year_mview;';
    EXECUTE 'DROP TABLE IF EXISTS ' || mview_name || ';';
    EXECUTE 'ALTER TABLE tmp_' || mview_name || ' RENAME TO ' || mview_name || ';';
  END;
$$;