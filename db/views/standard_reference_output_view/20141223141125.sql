WITH RECURSIVE inherited_references AS (
  SELECT id, taxon_concept_id, excluded_taxon_concepts_ids AS exclusions,
  is_cascaded
  FROM taxon_concept_references
  WHERE is_standard = true
  UNION
  SELECT d.id, low.id, d.exclusions, d.is_cascaded
  FROM taxon_concepts low
  JOIN inherited_references d ON d.taxon_concept_id = low.parent_id
  WHERE NOT COALESCE(d.exclusions, ARRAY[]::INT[]) @> ARRAY[low.id]
  AND d.is_cascaded
)
SELECT
taxon_concepts.id,
taxon_concepts.legacy_id,
taxon_concepts.data->'kingdom_name' AS kingdom_name,
taxon_concepts.data->'phylum_name' AS phylum_name,
taxon_concepts.data->'class_name' AS class_name,
taxon_concepts.data->'order_name' AS order_name,
taxon_concepts.data->'family_name' AS family_name,
taxon_concepts.data->'genus_name' AS genus_name,
taxon_concepts.data->'species_name' AS species_name,
taxon_concepts.full_name AS full_name,
taxon_concepts.author_year,
taxon_concepts.taxonomic_position AS taxonomic_position,
taxon_concepts.data->'rank_name' AS rank_name,
taxon_concepts.name_status,
taxonomies.name AS taxonomy,
taxonomies.id AS taxonomy_id,
r.id AS reference_id,
r.legacy_id AS reference_legacy_id,
r.citation,
CASE
  WHEN issued_for.id IS NOT NULL AND issued_for.id <> taxon_concepts.id
    THEN issued_for.full_name
  ELSE ''
END AS inherited_from,
CASE
  WHEN issued_for.id IS NOT NULL AND issued_for.id = taxon_concepts.id
  THEN
  array_to_string(
    ARRAY(SELECT taxon_concepts.full_name
    FROM UNNEST(inherited_references.exclusions) s
    INNER JOIN taxon_concepts ON taxon_concepts.id = s
    WHERE s IS NOT NULL), ', ')
  ELSE ''
END AS exclusions,
inherited_references.is_cascaded,
to_char(taxon_concept_references.created_at, 'DD/MM/YYYY') AS created_at,
uc.name AS created_by,
to_char(taxon_concept_references.updated_at, 'DD/MM/YYYY') AS updated_at,
uu.name AS updated_by
FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
LEFT JOIN inherited_references ON taxon_concepts.id = inherited_references.taxon_concept_id
LEFT JOIN taxon_concept_references ON taxon_concept_references.id = inherited_references.id
LEFT JOIN "references" AS r ON r.id = taxon_concept_references.reference_id
LEFT JOIN taxon_concepts AS issued_for ON issued_for.id = taxon_concept_references.taxon_concept_id
LEFT JOIN users uc ON taxon_concept_references.created_by_id = uc.id
LEFT JOIN users uu ON taxon_concept_references.updated_by_id = uu.id
WHERE taxon_concepts.name_status IN ('N', 'A')
ORDER BY citation
