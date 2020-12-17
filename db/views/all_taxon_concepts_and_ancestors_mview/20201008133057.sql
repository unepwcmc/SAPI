SELECT id AS taxon_concept_id, taxonomy_id,
(
  data->(LOWER(UNNEST(higher_or_equal_ranks_names(data->'rank_name'))) || '_id')
)::INT AS ancestor_taxon_concept_id,
GENERATE_SUBSCRIPTS(higher_or_equal_ranks_names(data->'rank_name'), 1) - 1 AS tree_distance
FROM taxon_concepts

-- This query is like taxon_concepts_and_ancestors_mview 
-- but it takes into consideration all taxa instead of just 'A', 'N' and 'H' names.
-- Amending the original one could have had undesired impact on several other queries and views.