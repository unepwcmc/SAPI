CREATE OR REPLACE FUNCTION applicable_listing_changes_for_node(node_id INT)
RETURNS TABLE (
  timeline_position INT,
  id INT
)
STABLE
AS $$

WITH RECURSIVE listing_changes_timeline AS (
  SELECT id, taxon_concept_id AS context, tree_distance AS context_tree_distance,
  taxon_concept_id, timeline_position, TRUE AS is_applicable
  FROM all_listing_changes_for_node(node_id)
  WHERE timeline_position = 1

  UNION

  SELECT hi.id,
  CASE
  WHEN hi.inclusion_taxon_concept_id IS NOT NULL
  THEN hi.inclusion_taxon_concept_id
  WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
  THEN hi.taxon_concept_id
  ELSE listing_changes_timeline.context
  END,
  hi.tree_distance,
  hi.taxon_concept_id, hi.timeline_position,
  CASE
  WHEN hi.taxon_concept_id = listing_changes_timeline.context
  THEN TRUE
  WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
  THEN TRUE
  ELSE FALSE
  END
  FROM all_listing_changes_for_node(node_id) hi
  JOIN listing_changes_timeline
  ON listing_changes_timeline.timeline_position + 1 = hi.timeline_position
)
SELECT ROW_NUMBER() OVER (ORDER BY timeline_position)::INT AS timeline_position,
listing_changes_timeline.id--listing_changes_mview.*
FROM listing_changes_timeline
--JOIN listing_changes_mview ON listing_changes_timeline.id = listing_changes_mview.id
WHERE is_applicable
ORDER BY timeline_position;
$$ LANGUAGE SQL;


COMMENT ON FUNCTION applicable_listing_changes_for_node(node_id INT) IS
  'Returns applicable listing changes for a given node, including own and ancestors.'
