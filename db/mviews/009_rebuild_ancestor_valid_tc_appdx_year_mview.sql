CREATE OR REPLACE FUNCTION rebuild_ancestor_valid_tc_appdx_year_mview_for_node(node_id INT) RETURNS VOID
  LANGUAGE plpgsql STRICT
  AS $$
    DECLARE
      children_node_ids INTEGER[];
      tmp_node_id INT;
    BEGIN
      SELECT ARRAY_AGG_NOTNULL(id) INTO children_node_ids
      FROM taxon_concepts
      WHERE parent_id = node_id;
      -- if there are children, rebuild their aggregated listing first
      FOREACH tmp_node_id IN ARRAY children_node_ids
      LOOP
        PERFORM rebuild_ancestor_valid_tc_appdx_year_mview_for_node(tmp_node_id);
      END LOOP;

      -- update this node's aggregated listing
      IF ARRAY_UPPER(children_node_ids, 1) IS NOT NULL THEN
        WITH children_intervals AS (
          SELECT taxon_concepts.id, taxon_concepts.parent_id, taxon_concepts.full_name
          FROM taxon_concepts
          JOIN valid_taxon_concept_appendix_year_mview t
          ON t.taxon_concept_id = taxon_concepts.id
          WHERE taxon_concepts.taxonomy_id = 1
          AND taxon_concepts.name_status IN ('A', 'N', 'H')
          AND taxon_concepts.parent_id = node_id
          GROUP BY taxon_concepts.id, taxon_concepts.parent_id, taxon_concepts.full_name
        )
        INSERT INTO valid_taxon_concept_appendix_year_mview
        (taxon_concept_id, appendix, effective_from, effective_to, cascaded_from_ancestors)
        SELECT COALESCE(parent_id, id) AS taxon_concept_id,
        appendix, effective_from, effective_to, FALSE
        FROM children_intervals
        JOIN valid_taxon_concept_appendix_year_mview t
        ON children_intervals.id = t.taxon_concept_id OR children_intervals.parent_id = t.taxon_concept_id
        GROUP BY COALESCE(parent_id, id), appendix, effective_from, effective_to;
      END IF;
    END;
  $$;

  CREATE OR REPLACE FUNCTION rebuild_ancestor_valid_tc_appdx_year_mview() RETURNS VOID
  LANGUAGE plpgsql
  AS $$
    DECLARE
      node_id INT;
    BEGIN
  FOR node_id IN SELECT taxon_concepts.id FROM taxon_concepts
    JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
    AND taxonomies.name = 'CITES_EU' AND name_status IN ('A', 'N', 'H')
    WHERE parent_id IS NULL
  LOOP
    PERFORM rebuild_ancestor_valid_tc_appdx_year_mview_for_node(node_id);
  END LOOP;
  RETURN;
    END;
  $$;