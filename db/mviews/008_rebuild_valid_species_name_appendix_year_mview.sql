CREATE OR REPLACE FUNCTION rebuild_valid_species_name_annex_year_mview() RETURNS VOID
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_valid_species_name_appendix_year_designation_mview('EU');
  END;
$$;

CREATE OR REPLACE FUNCTION rebuild_valid_species_name_appendix_year_mview() RETURNS VOID
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_valid_species_name_appendix_year_designation_mview('CITES');
  END;
$$;

CREATE OR REPLACE FUNCTION rebuild_valid_species_name_appendix_year_designation_mview(
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
    mview_name := 'valid_species_name_' || appendix || '_year_mview';

    EXECUTE 'DROP TABLE IF EXISTS tmp_' || mview_name;

    EXECUTE 'CREATE TABLE tmp_' || mview_name || ' AS
    WITH appendices AS (
      SELECT
        taxon_concept_id,
        ARRAY_AGG(species_listing_name)::TEXT[] AS appendix,
        EXTRACT(YEAR FROM effective_at)::INT AS appendix_year
      FROM '|| designation_name || '_listing_changes_mview lc
      WHERE change_type_name = ''ADDITION''
      GROUP BY taxon_concept_id, EXTRACT(YEAR FROM effective_at)
    )
    SELECT
      taxon_concepts.full_name species_name,
      taxon_concepts.id taxon_concept_id,
      appendix_year "year",
      CASE
        WHEN appendix IS NOT NULL THEN appendix
        ELSE FIRST_VALUE(appendix) OVER (PARTITION BY taxon_concept_id, c ORDER BY appendix_year)
      END ' || appendix || '
    FROM (
      SELECT
          a.taxon_concept_id,
          a.appendix_year,
          s.appendix,
          COUNT(appendix) OVER (PARTITION BY a.taxon_concept_id ORDER BY a.appendix_year) c
      FROM (
        SELECT taxon_concept_id, g.d::INT appendix_year
        FROM
        (
            SELECT DISTINCT taxon_concept_id
            FROM appendices
        ) s
        CROSS JOIN
          generate_series(
            1975,
            EXTRACT(YEAR FROM NOW())::INT,
            1
          ) g(d)
        ) a
        LEFT JOIN appendices s
        ON a.taxon_concept_id = s.taxon_concept_id
        AND a.appendix_year = s.appendix_year
    ) s
    JOIN taxon_concepts ON taxon_concepts.id = s.taxon_concept_id';

    EXECUTE 'CREATE INDEX ON tmp_' || mview_name || ' (species_name, ' || appendix || ', year)';

    EXECUTE 'DROP TABLE IF EXISTS ' || mview_name;
    EXECUTE 'ALTER TABLE tmp_' || mview_name || ' RENAME TO ' || mview_name;

  END;
$$;