CREATE OR REPLACE FUNCTION rebuild_valid_tc_appdx_N_year_mview() RETURNS VOID
LANGUAGE sql
AS $$

  WITH unmerged_eu_intervals AS (
    SELECT F.effective_from, L.effective_to, F.taxon_concept_id
    FROM valid_taxon_concept_annex_year_mview AS F
    JOIN valid_taxon_concept_annex_year_mview AS L
    ON (F.effective_to <= L.effective_to OR L.effective_to IS NULL)
      AND F.taxon_concept_id = L.taxon_concept_id
    JOIN valid_taxon_concept_annex_year_mview AS E
    ON F.taxon_concept_id = E.taxon_concept_id
    GROUP  BY F.effective_from, L.effective_to,  F.taxon_concept_id
    HAVING COUNT(
      CASE
        WHEN (E.effective_from < F.effective_from AND (F.effective_from <= E.effective_to OR E.effective_to IS NULL))
          OR (E.effective_from <= L.effective_to AND (L.effective_to < E.effective_to OR E.effective_to IS NULL))
        THEN 1
      END
    ) = 0
  ), eu_intervals AS (
    SELECT taxon_concept_id, effective_from, MIN(effective_to) AS effective_to
    FROM   unmerged_eu_intervals
    GROUP  BY taxon_concept_id, effective_from
  ), unmerged_cites_intervals AS (
    SELECT F.effective_from, L.effective_to, F.taxon_concept_id
    FROM valid_taxon_concept_appendix_year_mview AS F
    JOIN valid_taxon_concept_appendix_year_mview AS L
    ON (F.effective_to <= L.effective_to OR L.effective_to IS NULL)
      AND F.taxon_concept_id = L.taxon_concept_id
    JOIN valid_taxon_concept_appendix_year_mview AS E
    ON F.taxon_concept_id = E.taxon_concept_id
    GROUP  BY F.effective_from, L.effective_to,  F.taxon_concept_id
    HAVING COUNT(
      CASE
        WHEN (E.effective_from < F.effective_from AND (F.effective_from <= E.effective_to OR E.effective_to IS NULL))
          OR (E.effective_from <= L.effective_to AND (L.effective_to < E.effective_to OR E.effective_to IS NULL))
        THEN 1
      END
    ) = 0
  ), cites_intervals AS (
    SELECT taxon_concept_id, effective_from, MIN(effective_to) AS effective_to
    FROM   unmerged_cites_intervals
    GROUP  BY taxon_concept_id, effective_from
  ), cites_gaps (taxon_concept_id, eu_effective_from, eu_effective_to, cites_effective_from, cites_effective_to) AS (
    SELECT eu_intervals.taxon_concept_id, eu_intervals.effective_from, eu_intervals.effective_to,
    cites_intervals.effective_from, cites_intervals.effective_to
    FROM eu_intervals
    LEFT JOIN cites_intervals
    ON eu_intervals.taxon_concept_id = cites_intervals.taxon_concept_id

    EXCEPT

    SELECT eu_intervals.taxon_concept_id, eu_intervals.effective_from, eu_intervals.effective_to,
    cites_intervals.effective_from, cites_intervals.effective_to
    FROM eu_intervals
    JOIN cites_intervals
    ON eu_intervals.taxon_concept_id = cites_intervals.taxon_concept_id
    AND cites_intervals.effective_from <= eu_intervals.effective_from
    AND (
      cites_intervals.effective_to >= eu_intervals.effective_to
      OR cites_intervals.effective_to IS NULL
    )
  )
  INSERT INTO valid_taxon_concept_appendix_year_mview (taxon_concept_id, appendix, effective_from, effective_to)
  SELECT taxon_concept_id, 'N',
  CASE
    WHEN cites_effective_from IS NULL THEN eu_effective_from
    WHEN eu_effective_from < cites_effective_from THEN eu_effective_from
    WHEN eu_effective_to > cites_effective_to OR (eu_effective_to IS NULL AND cites_effective_to IS NOT NULL) THEN cites_effective_to
    ELSE cites_effective_from
  END AS effective_from,
  CASE
    WHEN cites_effective_from IS NULL THEN eu_effective_to
    WHEN eu_effective_to > cites_effective_to OR (eu_effective_to IS NULL AND cites_effective_to IS NOT NULL) THEN eu_effective_to
    WHEN eu_effective_from < cites_effective_from THEN cites_effective_from
    ELSE cites_effective_to
  END AS effective_to
  FROM cites_gaps;

$$;
