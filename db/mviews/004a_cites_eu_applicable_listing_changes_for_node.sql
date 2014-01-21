DROP FUNCTION IF EXISTS cites_eu_applicable_listing_changes_for_node(designation_name TEXT, node_id INT);
CREATE OR REPLACE FUNCTION cites_eu_applicable_listing_changes_for_node(all_listing_changes_mview TEXT, node_id INT)
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
    CASE
      WHEN inclusion_taxon_concept_id IS NULL
      THEN HSTORE(species_listing_id::TEXT, taxon_concept_id::TEXT)
      ELSE HSTORE(species_listing_id::TEXT, inclusion_taxon_concept_id::TEXT)
    END AS context,
    inclusion_taxon_concept_id,
    species_listing_id,
    change_type_id,
    event_id,
    effective_at,
    tree_distance AS context_tree_distance,
    timeline_position,
    CASE
     WHEN (
      -- there are listed populations
      ARRAY_UPPER(listed_geo_entities_ids, 1) IS NOT NULL
      -- and the taxon has its own distribution and does not occur in any of them
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND NOT listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
    )
    -- when all populations are excluded
    OR (
      ARRAY_UPPER(excluded_geo_entities_ids, 1) IS NOT NULL
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
    )
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
    FROM ' || all_listing_changes_mview || ' all_listing_changes_mview
    JOIN cites_eu_tmp_taxon_concepts_mview taxon_concepts_mview
    ON all_listing_changes_mview.affected_taxon_concept_id = taxon_concepts_mview.id
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
    AND hi.taxon_concept_id = hi.affected_taxon_concept_id
    THEN listing_changes_timeline.context - ARRAY[hi.species_listing_id::TEXT]
    WHEN change_types.name = ''DELETION''
    THEN listing_changes_timeline.context - HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    -- if it is a new listing at closer level that replaces an older listing, wipe out the context
    WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
    AND hi.effective_at > listing_changes_timeline.effective_at
    AND change_types.name = ''ADDITION''
    THEN HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
    -- if it is a same day split listing we don''t want to wipe the other part of the split from the context
    WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
    AND change_types.name = ''ADDITION''
    THEN listing_changes_timeline.context || HSTORE(hi.species_listing_id::TEXT, hi.taxon_concept_id::TEXT)
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
    hi.event_id,
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
      -- and the taxon has its own distribution and does not occur in any of them
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND NOT hi.listed_geo_entities_ids && taxon_concepts_mview.countries_ids_ary
    )
    -- when all populations are excluded
    OR (
      ARRAY_UPPER(hi.excluded_geo_entities_ids, 1) IS NOT NULL
      AND ARRAY_UPPER(taxon_concepts_mview.countries_ids_ary, 1) IS NOT NULL
      AND hi.excluded_geo_entities_ids @> taxon_concepts_mview.countries_ids_ary
    )
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
    -- this line to make Moschus leucogaster happy
    OR AVALS(listing_changes_timeline.context) @> ARRAY[hi.taxon_concept_id::TEXT]
    THEN TRUE
    WHEN listing_changes_timeline.context = ''''::HSTORE  --this would be the case when deleted
    AND (
      ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NOT NULL
      AND NOT hi.excluded_taxon_concept_ids && ARRAY[hi.affected_taxon_concept_id]
      OR ARRAY_UPPER(hi.excluded_taxon_concept_ids, 1) IS NULL
    )
    AND hi.inclusion_taxon_concept_id IS NULL
    AND hi.change_type_name = ''ADDITION''
    THEN TRUE -- allows for re-listing
    WHEN hi.tree_distance < listing_changes_timeline.context_tree_distance
    THEN TRUE
    ELSE FALSE
    END
    FROM ' || all_listing_changes_mview || ' hi
    JOIN listing_changes_timeline
    ON hi.designation_id = listing_changes_timeline.designation_id
    AND listing_changes_timeline.original_taxon_concept_id = hi.affected_taxon_concept_id
    AND listing_changes_timeline.timeline_position + 1 = hi.timeline_position
    JOIN change_types ON hi.change_type_id = change_types.id
    JOIN cites_eu_tmp_taxon_concepts_mview taxon_concepts_mview
    ON hi.affected_taxon_concept_id = taxon_concepts_mview.id
  )
  SELECT listing_changes_timeline.id
  FROM listing_changes_timeline
  WHERE is_applicable
  ORDER BY timeline_position';

  RETURN QUERY EXECUTE sql USING node_id;
END;
$$;


DROP FUNCTION IF EXISTS cites_applicable_listing_changes_for_node(node_id INT);
CREATE OR REPLACE FUNCTION cites_applicable_listing_changes_for_node(all_listing_changes_mview TEXT, node_id INT)
RETURNS SETOF INT
LANGUAGE SQL STRICT
STABLE
AS $$
  SELECT * FROM cites_eu_applicable_listing_changes_for_node($1, $2);
$$;

COMMENT ON FUNCTION cites_applicable_listing_changes_for_node(all_listing_changes_mview TEXT, node_id INT) IS
  'Returns applicable listing changes for a given node, including own and ancestors (following CITES cascading rules).';

DROP FUNCTION IF EXISTS eu_applicable_listing_changes_for_node(node_id INT);
CREATE OR REPLACE FUNCTION eu_applicable_listing_changes_for_node(all_listing_changes_mview TEXT, node_id INT)
RETURNS SETOF INT
LANGUAGE SQL STRICT
STABLE
AS $$
  SELECT * FROM cites_eu_applicable_listing_changes_for_node($1, $2);
$$;

COMMENT ON FUNCTION eu_applicable_listing_changes_for_node(all_listing_changes_mview TEXT, node_id INT) IS
  'Returns applicable listing changes for a given node, including own and ancestors (following EU cascading rules).';
