CREATE OR REPLACE FUNCTION all_listing_changes_for_node(node_id INT)
RETURNS TABLE (
  timeline_position INT,
  id INT,
  taxon_concept_id INT,
  species_listing_id INT,
  change_type_id INT,
  inclusion_taxon_concept_id INT,
  effective_at DATE,
  tree_distance INT
)
STABLE
AS $$
WITH RECURSIVE self_and_ancestors AS (
  SELECT id, parent_id, 0 AS tree_distance
  FROM taxon_concepts WHERE id = node_id
  UNION
  SELECT hi.id, hi.parent_id, self_and_ancestors.tree_distance + 1
  FROM taxon_concepts hi
  JOIN self_and_ancestors ON self_and_ancestors.parent_id = hi.id
)
SELECT ROW_NUMBER() OVER (ORDER BY effective_at, tree_distance)::INT AS timeline_position,
    listing_changes.id,
    taxon_concept_id,
    species_listing_id,
    change_type_id,
    inclusion_taxon_concept_id,
    effective_at::DATE,
    self_and_ancestors.tree_distance
FROM listing_changes
JOIN self_and_ancestors ON listing_changes.taxon_concept_id = self_and_ancestors.id
JOIN change_types ON change_types.id = listing_changes.change_type_id
JOIN designations ON designations.id = change_types.designation_id AND designations.name = 'CITES';
$$ LANGUAGE SQL;


COMMENT ON FUNCTION all_listing_changes_for_node(node_id INT) IS
  'Returns all potentially applicable listing changes for a given node, including own and ancestors.'
