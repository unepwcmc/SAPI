WITH RECURSIVE all_tc_refs AS (
  SELECT
    id,
    taxon_concept_id,
    reference_id,
    excluded_taxon_concepts_ids AS exclusions,
    is_cascaded,
    is_standard
  FROM taxon_concept_references

  UNION

  SELECT
    h.id,
    hi.id,
    h.reference_id,
    h.exclusions,
    h.is_cascaded,
    h.is_standard
  FROM taxon_concepts hi
  JOIN all_tc_refs h
  ON h.taxon_concept_id = hi.parent_id
    AND NOT COALESCE(h.exclusions, ARRAY[]::INT[]) @> ARRAY[hi.id]
    AND h.is_cascaded
    AND h.is_standard
)
SELECT
  all_tc_refs.id,
  all_tc_refs.taxon_concept_id,
  all_tc_refs.reference_id,
  all_tc_refs.is_standard,
  refs.citation
FROM all_tc_refs
JOIN "references" refs ON refs.id = all_tc_refs.reference_id;

-- A more efficient approach that could also be used in other places:
-- cites_eu_taxon_concepts_and_ancestors_mview is currently created as a temp table
-- as part of the rebuild script
-- WITH all_tc_refs AS (
--   SELECT
--     tcr.id,
--     tcr.reference_id,
--     tcr.excluded_taxon_concepts_ids AS exclusions,
--     tcr.is_cascaded,
--     tcr.is_standard,
--     t.taxon_concept_id
--   FROM taxon_concept_references tcr
--   JOIN cites_eu_taxon_concepts_and_ancestors_mview t
--   ON t.ancestor_taxon_concept_id = tcr.taxon_concept_id
--   WHERE NOT COALESCE(tcr.excluded_taxon_concepts_ids, ARRAY[]::INT[]) @> ARRAY[t.taxon_concept_id]
-- )
-- SELECT
--   all_tc_refs.id,
--   all_tc_refs.taxon_concept_id,
--   all_tc_refs.reference_id,
--   all_tc_refs.is_standard,
--   refs.citation
-- FROM all_tc_refs
-- JOIN "references" refs ON refs.id = all_tc_refs.reference_id
