WITH cascaded_tc_refs AS (
  SELECT tc_refs_1.id,
    tc.taxon_concept_id,
    tc.ancestor_taxon_concept_id AS original_taxon_concept_id,
    tc_refs_1.excluded_taxon_concepts_ids,
    tc_refs_1.reference_id,
    tc_refs_1.is_standard,
    tc_refs_1.is_cascaded
  FROM taxon_concept_references tc_refs_1
    JOIN taxon_concepts_and_ancestors_mview tc ON tc_refs_1.is_standard AND tc_refs_1.is_cascaded AND tc.ancestor_taxon_concept_id = tc_refs_1.taxon_concept_id
), cascaded_tc_refs_without_exclusions AS (
  SELECT cascaded_tc_refs.id,
    cascaded_tc_refs.taxon_concept_id,
    cascaded_tc_refs.original_taxon_concept_id,
    cascaded_tc_refs.excluded_taxon_concepts_ids,
    cascaded_tc_refs.reference_id,
    cascaded_tc_refs.is_standard,
    cascaded_tc_refs.is_cascaded
  FROM cascaded_tc_refs
  JOIN taxon_concepts tc ON cascaded_tc_refs.taxon_concept_id = tc.id
  WHERE cascaded_tc_refs.excluded_taxon_concepts_ids IS NULL
  OR NOT ARRAY[
    (tc.data->'kingdom_id')::INT,
    (tc.data->'phylum_id')::INT,
    (tc.data->'class_id')::INT,
    (tc.data->'order_id')::INT,
    (tc.data->'family_id')::INT,
    (tc.data->'subfamily_id')::INT,
    (tc.data->'genus_id')::INT,
    (tc.data->'species_id')::INT
  ] && cascaded_tc_refs.excluded_taxon_concepts_ids
), tc_refs AS (
  SELECT cascaded_tc_refs_without_exclusions.id,
    cascaded_tc_refs_without_exclusions.taxon_concept_id,
    cascaded_tc_refs_without_exclusions.original_taxon_concept_id,
    cascaded_tc_refs_without_exclusions.excluded_taxon_concepts_ids,
    cascaded_tc_refs_without_exclusions.reference_id,
    cascaded_tc_refs_without_exclusions.is_standard
  FROM cascaded_tc_refs_without_exclusions
UNION ALL
  SELECT taxon_concept_references.id,
    taxon_concept_references.taxon_concept_id,
    taxon_concept_references.taxon_concept_id,
    taxon_concept_references.excluded_taxon_concepts_ids,
    taxon_concept_references.reference_id,
    taxon_concept_references.is_standard
  FROM taxon_concept_references
  WHERE NOT (taxon_concept_references.is_standard AND taxon_concept_references.is_cascaded)
)
SELECT tc_refs.id,
  tc_refs.taxon_concept_id,
  tc_refs.original_taxon_concept_id,
  tc_refs.excluded_taxon_concepts_ids,
  tc_refs.reference_id,
  tc_refs.is_standard,
  "references".citation
FROM tc_refs
JOIN "references" ON "references".id = tc_refs.reference_id;
