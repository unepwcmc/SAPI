CREATE OR REPLACE FUNCTION cites_eu_applicable_listing_changes_for_node(designation_name TEXT, node_id INT)
RETURNS SETOF INT
LANGUAGE plpgsql STRICT
STABLE
AS $$
DECLARE
  sql TEXT;
BEGIN
  sql := 'WITH RECURSIVE listing_changes_timeline AS (
    SELECT all_listing_changes_mview.id,
    designation_id,
    affected_taxon_concept_id AS original_taxon_concept_id,
    taxon_concept_id AS current_taxon_concept_id,
    HSTORE(species_listing_id::TEXT, taxon_concept_id::TEXT) AS context,
    inclusion_taxon_concept_id,
    species_listing_id,
    change_type_id,
    effective_at,
    tree_distance AS context_tree_distance,
    timeline_position,
    CASE
     WHEN (
      -- there are listed populations
      ARRAY_UPPER(listed_geo_entities_ids, 1) IS NOT NULL
      -- and the taxon does not occur in any of them
      AND NOT listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
    )
    -- when all populations are excluded
    OR excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
    THEN FALSE
    WHEN ARRAY_UPPER(excluded_taxon_concept_ids, 1) IS NOT NULL 
    -- if taxon or any of its ancestors is excluded from this listing
    AND excluded_taxon_concept_ids && ARRAY[
      affected_taxon_concept_id,
      taxon_concepts_mview.kingdom_id,
      taxon_concepts_mview.phylum_id,
      taxon_concepts_mview.class_id,
      taxon_concepts_mview.order_id,
      taxon_concepts_mview.family_id,
      taxon_concepts_mview.genus_id,
      taxon_concepts_mview.species_id
    ]
    THEN FALSE
    ELSE
    TRUE 
    END AS is_applicable
    FROM ' || LOWER(designation_name) || '_all_listing_changes_mview all_listing_changes_mview
    JOIN taxon_concepts_mview ON all_listing_changes_mview.affected_taxon_concept_id = taxon_concepts_mview.id 
    WHERE all_listing_changes_mview.affected_taxon_concept_id = $1
    AND timeline_position = 1

    UNION

    SELECT hi.id,
    hi.designation_id,
    listing_changes_timeline.original_taxon_concept_id,
    hi.taxon_concept_id,
    CASE
    WHEN hi.inclusion_taxon_concept_id IS NOT NULL
    AND (
      AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
      OR listing_changes_timeline.context = ''''::HSTORE
    )
    THEN HSTORE(hi.species_listing_id::TEXT, hi.inclusion_taxon_concept_id::TEXT)
    WHEN change_types.name = ''DELETION''
    THEN listing_changes_timeline.context - HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
    AND change_types.name = ''ADDITION''
    THEN HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    WHEN hi.tree_distance <= listing_changes_timeline.context_tree_distance
    AND hi.affected_taxon_concept_id = hi.taxon_concept_id
    AND change_types.name = ''ADDITION''
    THEN HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    -- changing this to <= breaks Ursus arctos isabellinus
    WHEN hi.tree_distance <= listing_changes_timeline.context_tree_distance
    AND change_types.name = ''ADDITION''
    THEN listing_changes_timeline.context || HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    ELSE listing_changes_timeline.context
    END,
    hi.inclusion_taxon_concept_id,
    hi.species_listing_id,
    hi.change_type_id,
    hi.effective_at,
    CASE 
    WHEN (
        hi.inclusion_taxon_concept_id IS NOT NULL
        AND AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
      ) OR hi.tree_distance < listing_changes_timeline.context_tree_distance
    THEN hi.tree_distance
    ELSE listing_changes_timeline.context_tree_distance
    END,
    hi.timeline_position,
    -- is applicable
    CASE
    WHEN (
      -- there are listed populations
      ARRAY_UPPER(hi.listed_geo_entities_ids, 1) IS NOT NULL
      -- and the taxon does not occur in any of them
      AND NOT hi.listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
    )
    -- when all populations are excluded
    OR hi.excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
    THEN FALSE
    WHEN ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NOT NULL 
    -- if taxon or any of its ancestors is excluded from this listing
    AND hi.excluded_taxon_concept_ids && ARRAY[
      hi.affected_taxon_concept_id,
      taxon_concepts_mview.kingdom_id,
      taxon_concepts_mview.phylum_id,
      taxon_concepts_mview.class_id,
      taxon_concepts_mview.order_id,
      taxon_concepts_mview.family_id,
      taxon_concepts_mview.genus_id,
      taxon_concepts_mview.species_id
    ]
    THEN FALSE
    WHEN listing_changes_timeline.context -> hi.species_listing_id::TEXT = hi.taxon_concept_id::TEXT
    OR hi.taxon_concept_id = listing_changes_timeline.original_taxon_concept_id
    THEN TRUE
    WHEN listing_changes_timeline.context = ''''::HSTORE  --this would be the case when deleted
    AND hi.change_type_name = ''ADDITION''
    THEN TRUE -- allows for re-listing
    WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
    THEN TRUE
    ELSE FALSE
    END
    FROM ' || LOWER(designation_name) || '_all_listing_changes_mview hi
    JOIN listing_changes_timeline
    ON hi.designation_id = listing_changes_timeline.designation_id
    AND listing_changes_timeline.original_taxon_concept_id = hi.affected_taxon_concept_id
    AND listing_changes_timeline.timeline_position + 1 = hi.timeline_position
    JOIN change_types ON hi.change_type_id = change_types.id
    JOIN taxon_concepts_mview ON hi.affected_taxon_concept_id = taxon_concepts_mview.id 
  )
  SELECT listing_changes_timeline.id
  FROM listing_changes_timeline
  WHERE is_applicable
  ORDER BY timeline_position';

  RETURN QUERY EXECUTE sql USING node_id;
END;
$$;

CREATE OR REPLACE FUNCTION cites_applicable_listing_changes_for_node(node_id INT)
RETURNS SETOF INT
LANGUAGE SQL STRICT
STABLE
AS $$
  SELECT * FROM cites_eu_applicable_listing_changes_for_node('CITES', $1);
$$;

COMMENT ON FUNCTION cites_applicable_listing_changes_for_node(node_id INT) IS
  'Returns applicable listing changes for a given node, including own and ancestors (following CITES cascading rules).';

CREATE OR REPLACE FUNCTION eu_applicable_listing_changes_for_node(node_id INT)
RETURNS SETOF INT
LANGUAGE SQL STRICT
STABLE
AS $$
  SELECT * FROM cites_eu_applicable_listing_changes_for_node('EU', $1);
$$;

COMMENT ON FUNCTION eu_applicable_listing_changes_for_node(node_id INT) IS
  'Returns applicable listing changes for a given node, including own and ancestors (following EU cascading rules).';
