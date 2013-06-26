CREATE OR REPLACE FUNCTION applicable_listing_changes_for_node(in_designation_id INT, node_id INT)
RETURNS SETOF  INT

STABLE
AS $$

WITH RECURSIVE listing_changes_timeline AS (
  SELECT id,
  taxon_concept_id AS original_taxon_concept_id,
  taxon_concept_id AS current_taxon_concept_id,
  taxon_concept_id AS context,
  tree_distance AS context_tree_distance,
  timeline_position, TRUE AS is_applicable
  FROM all_listing_changes_view
  WHERE designation_id = in_designation_id
  AND all_listing_changes_view.original_taxon_concept_id = node_id
  AND timeline_position = 1

  UNION

  SELECT hi.id,
  listing_changes_timeline.original_taxon_concept_id,
  hi.taxon_concept_id,
  CASE
  WHEN hi.inclusion_taxon_concept_id IS NOT NULL
  THEN hi.inclusion_taxon_concept_id
  WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
  THEN hi.taxon_concept_id
  ELSE listing_changes_timeline.context
  END,
  hi.tree_distance,
  hi.timeline_position,
  CASE
  WHEN hi.taxon_concept_id = listing_changes_timeline.context
  THEN TRUE
  WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
  THEN TRUE
  ELSE FALSE
  END
  FROM all_listing_changes_view hi
  JOIN listing_changes_timeline
  ON designation_id = in_designation_id
  AND listing_changes_timeline.original_taxon_concept_id = hi.original_taxon_concept_id
  AND listing_changes_timeline.timeline_position + 1 = hi.timeline_position
)
SELECT listing_changes_timeline.id
FROM listing_changes_timeline
WHERE is_applicable
ORDER BY timeline_position;
$$ LANGUAGE SQL;

COMMENT ON FUNCTION applicable_listing_changes_for_node(in_designation_id INT, node_id INT) IS
  'Returns applicable listing changes for a given node, including own and ancestors.'
