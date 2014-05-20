CREATE OR REPLACE FUNCTION rebuild_valid_hybrid_appdx_year_mview() RETURNS VOID
LANGUAGE sql
AS $$
  WITH hybrids AS (
    SELECT other_taxon_concept_id AS hybrid_id,
    taxon_concept_id
    FROM taxon_relationships rel
    JOIN taxon_relationship_types rel_type
    ON rel.taxon_relationship_type_id = rel_type.id AND rel_type.name = 'HAS_HYBRID'
  )
  INSERT INTO valid_taxon_concept_appendix_year_mview (
    taxon_concept_id, appendix, effective_from, effective_to
  )
  SELECT hybrids.hybrid_id, appendix, effective_from, effective_to
  FROM valid_taxon_concept_appendix_year_mview intervals
  JOIN hybrids
  ON hybrids.taxon_concept_id = intervals.taxon_concept_id;
$$;
