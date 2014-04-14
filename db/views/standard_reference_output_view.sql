DROP VIEW IF EXISTS standard_reference_output_view;
CREATE VIEW standard_reference_output_view AS

WITH RECURSIVE inherited_references AS (
  SELECT id, taxon_concept_id, excluded_taxon_concepts_ids AS exclusions
  FROM taxon_concept_references
  WHERE is_standard = true
  UNION
  SELECT d.id, low.id, d.exclusions
  FROM taxon_concepts low
  JOIN inherited_references d ON d.taxon_concept_id = low.parent_id
  WHERE NOT COALESCE(d.exclusions, ARRAY[]::INT[]) @> ARRAY[low.id]
)
SELECT 
taxon_concepts.id,
taxon_concepts.legacy_id,
taxon_concepts.data->'phylum_name' AS accepted_phylum_name,
taxon_concepts.data->'class_name' AS accepted_class_name,
taxon_concepts.data->'order_name' AS accepted_order_name,
taxon_concepts.data->'family_name' AS accepted_family_name,
taxon_concepts.data->'genus_name' AS accepted_genus_name,
taxon_concepts.data->'species_name' AS accepted_species_name,
taxon_concepts.full_name AS full_name,
taxon_concepts.data->'rank_name' AS rank_name,
taxon_concepts.name_status,
taxonomies.name AS taxonomy,
--taxon_concepts.parent_id as inherited_from
r.id AS reference_id,
r.legacy_id AS reference_legacy_id,
r.citation, 
issued_for.full_name AS issued_for,
array_to_string(
  ARRAY(SELECT taxon_concepts.full_name
  FROM UNNEST(inherited_references.exclusions) s
  INNER JOIN taxon_concepts ON taxon_concepts.id = s
  WHERE s IS NOT NULL), ', ') AS exclusions,
to_char(taxon_concepts.created_at, 'DD/MM/YYYY') AS created_at,
'TODO' AS created_by
FROM taxon_concepts
JOIN taxonomies ON taxonomies.id = taxon_concepts.taxonomy_id
LEFT JOIN inherited_references ON taxon_concepts.id = inherited_references.taxon_concept_id
LEFT JOIN taxon_concept_references ON taxon_concept_references.id = inherited_references.id
LEFT JOIN "references" AS r ON r.id = taxon_concept_references.reference_id
LEFT JOIN taxon_concepts AS issued_for ON issued_for.id = taxon_concept_references.taxon_concept_id
WHERE taxon_concepts.name_status IN ('N', 'A')
ORDER BY citation
