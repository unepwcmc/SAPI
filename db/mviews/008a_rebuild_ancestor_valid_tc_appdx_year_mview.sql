CREATE OR REPLACE FUNCTION rebuild_ancestor_valid_tc_appdx_year_designation_mview_for_node(designation_name VARCHAR, node_id INT) RETURNS VOID
  LANGUAGE plpgsql STRICT
  AS $$
    DECLARE
      children_node_ids INTEGER[];
      tmp_node_id INT;
      mview_name VARCHAR;
      appendix VARCHAR;
      sql TEXT;
    BEGIN
      SELECT ARRAY_AGG_NOTNULL(id) INTO children_node_ids
      FROM taxon_concepts
      WHERE parent_id = node_id;
      -- if there are children, rebuild their aggregated listing first
      FOREACH tmp_node_id IN ARRAY children_node_ids
      LOOP
        PERFORM rebuild_ancestor_valid_tc_appdx_year_designation_mview_for_node(designation_name, tmp_node_id);
      END LOOP;

      IF ARRAY_UPPER(children_node_ids, 1) IS NOT NULL THEN
        IF designation_name = 'EU' THEN
          appendix := 'annex';
        ELSE
          appendix := 'appendix';
        END IF;

        mview_name := 'valid_taxon_concept_' || appendix || '_year_mview';
        -- update this node's aggregated listing
        sql := '
          WITH children_intervals AS (
            SELECT taxon_concepts.id, taxon_concepts.parent_id, taxon_concepts.full_name
            FROM taxon_concepts
            JOIN ' || mview_name || ' t
            ON t.taxon_concept_id = taxon_concepts.id
            WHERE taxon_concepts.name_status IN (''A'', ''N'', ''H'')
            AND taxon_concepts.parent_id = ' || node_id || '
            GROUP BY taxon_concepts.id, taxon_concepts.parent_id, taxon_concepts.full_name
          )
          INSERT INTO ' || mview_name || '
          (taxon_concept_id, ' || appendix || ', effective_from, effective_to)
          SELECT COALESCE(parent_id, id) AS taxon_concept_id,
          ' || appendix || ', effective_from, effective_to
          FROM children_intervals
          JOIN ' || mview_name || ' t
          ON children_intervals.id = t.taxon_concept_id OR children_intervals.parent_id = t.taxon_concept_id
          GROUP BY COALESCE(parent_id, id), ' || appendix || ', effective_from, effective_to';
        EXECUTE sql;
      END IF;
    END;
  $$;

  CREATE OR REPLACE FUNCTION rebuild_ancestor_valid_tc_appdx_year_designation_mview(designation_name VARCHAR) RETURNS VOID
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
    PERFORM rebuild_ancestor_valid_tc_appdx_year_designation_mview_for_node(designation_name, node_id);
  END LOOP;
  RETURN;
    END;
  $$;
