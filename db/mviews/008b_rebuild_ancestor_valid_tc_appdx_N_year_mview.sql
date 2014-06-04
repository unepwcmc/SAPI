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
    SELECT taxon_concept_id, effective_from, MIN(effective_to) AS effective_to,
    daterange(effective_from::date, MIN(effective_to)::date, '[]'::text) AS listing_interval
    FROM   unmerged_cites_intervals
    GROUP  BY taxon_concept_id, effective_from
  ), cites_intervals_with_lag AS (
    SELECT taxon_concept_id, listing_interval AS current,
    LAG(listing_interval) OVER (PARTITION BY taxon_concept_id ORDER BY LOWER(listing_interval)) AS previous
    FROM cites_intervals
  ), cites_intervals_with_lead AS (
    SELECT taxon_concept_id, listing_interval AS current,
    LEAD(listing_interval) OVER (PARTITION BY taxon_concept_id ORDER BY LOWER(listing_interval)) AS next
    FROM cites_intervals
  ), cites_gaps (taxon_concept_id, gap_effective_from, gap_effective_to) AS (
    SELECT taxon_concept_id, UPPER(previous), LOWER(current) FROM cites_intervals_with_lag
    UNION
    SELECT taxon_concept_id, UPPER(current), LOWER(next) FROM cites_intervals_with_lead
    WHERE UPPER(current) IS NOT NULL
  )
  INSERT INTO valid_taxon_concept_appendix_year_mview (taxon_concept_id, appendix, effective_from, effective_to)
  SELECT
    cites_gaps.taxon_concept_id, 'N',
    GREATEST(COALESCE(gap_effective_from, effective_from), effective_from) effective_from,
    LEAST(COALESCE(gap_effective_to, effective_to), effective_to) AS effective_to
  FROM cites_gaps
  JOIN eu_intervals
  ON eu_intervals.taxon_concept_id = cites_gaps.taxon_concept_id
  AND (
    -- gap is right closed
    gap_effective_to IS NOT NULL
    AND effective_from < gap_effective_to
    OR
    -- gap is right open
    gap_effective_to IS NULL
    AND (effective_to IS NULL OR effective_to > gap_effective_from)
  )
  UNION

  SELECT eu_intervals.taxon_concept_id, 'N', eu_intervals.effective_from, eu_intervals.effective_to
  FROM eu_intervals
  LEFT JOIN cites_gaps
  ON eu_intervals.taxon_concept_id = cites_gaps.taxon_concept_id
  WHERE cites_gaps.taxon_concept_id IS NULL;

$$;
