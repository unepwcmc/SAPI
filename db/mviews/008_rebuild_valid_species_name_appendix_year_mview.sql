CREATE OR REPLACE FUNCTION rebuild_valid_species_name_appendix_year_mview() RETURNS VOID
  LANGUAGE plpgsql
  AS $$
  BEGIN

  DROP TABLE IF EXISTS valid_species_name_appendix_year_mview_tmp;

  CREATE TABLE valid_species_name_appendix_year_mview_tmp AS
  WITH appendices AS (
    SELECT
      taxon_concept_id,
      ARRAY_AGG(species_listing_name)::TEXT[] AS appendix,
      EXTRACT(YEAR FROM effective_at)::INT AS appendix_year
    FROM listing_changes_mview lc
    WHERE designation_name = 'CITES'
      AND change_type_name = 'ADDITION'
    GROUP BY taxon_concept_id, EXTRACT(YEAR FROM effective_at)
  )
  SELECT
    taxon_concepts.full_name species_name,
    appendix_year "year",
    CASE
      WHEN appendix IS NOT NULL THEN appendix
      ELSE FIRST_VALUE(appendix) OVER (PARTITION BY taxon_concept_id, c ORDER BY appendix_year)
    END appendix
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
  JOIN taxon_concepts ON taxon_concepts.id = s.taxon_concept_id;

  CREATE INDEX ON valid_species_name_appendix_year_mview_tmp (species_name, appendix, year);

  DROP TABLE IF EXISTS valid_species_name_appendix_year_mview;
  ALTER TABLE valid_species_name_appendix_year_mview_tmp RENAME TO valid_species_name_appendix_year_mview;

END;
$$;