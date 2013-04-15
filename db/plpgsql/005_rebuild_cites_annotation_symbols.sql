CREATE OR REPLACE FUNCTION rebuild_cites_annotation_symbols_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    UPDATE annotations
    SET symbol = ordered_annotations.calculated_symbol, parent_symbol = NULL
    FROM
    (
      SELECT ROW_NUMBER() OVER(ORDER BY kingdom_position, full_name) AS calculated_symbol, MAX(annotations.id) AS id
      FROM listing_changes
      INNER JOIN annotations
        ON listing_changes.annotation_id = annotations.id
      INNER JOIN change_types
        ON listing_changes.change_type_id = change_types.id
      INNER JOIN designations
        ON change_types.designation_id = designations.id AND designations.name = 'CITES'
      INNER JOIN taxon_concepts_mview
        ON listing_changes.taxon_concept_id = taxon_concepts_mview.id
      WHERE is_current = TRUE AND display_in_index = TRUE
      GROUP BY taxon_concept_id, kingdom_position, full_name
      ORDER BY kingdom_position, full_name
    ) ordered_annotations
    WHERE ordered_annotations.id = annotations.id;

    --clear all annotation symbols (non-hash ones)
    UPDATE taxon_concepts
    SET listing = listing - ARRAY['ann_symbol'];

    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) || hstore('ann_symbol', taxon_concept_annotations.symbol)
    FROM
    (
      SELECT taxon_concept_id, MAX(annotations.symbol) AS symbol
      FROM listing_changes
      INNER JOIN annotations
        ON listing_changes.annotation_id = annotations.id
      INNER JOIN change_types
        ON listing_changes.change_type_id = change_types.id
      INNER JOIN designations
        ON change_types.designation_id = designations.id AND designations.name = 'CITES'
      WHERE is_current = TRUE AND display_in_index = TRUE
      GROUP BY taxon_concept_id
    ) taxon_concept_annotations
    WHERE
      taxon_concept_annotations.taxon_concept_id = taxon_concepts.id;
    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cites_hash_annotation_symbols_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN

    UPDATE taxon_concepts
    SET listing = listing - ARRAY['hash_ann_symbol', 'hash_ann_parent_symbol']
    WHERE CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    UPDATE taxon_concepts
    SET listing = COALESCE(listing, ''::HSTORE) ||
      hstore('hash_ann_symbol', taxon_concept_hash_annotations.symbol) ||
      hstore('hash_ann_parent_symbol', taxon_concept_hash_annotations.parent_symbol)
    FROM
    (
      SELECT taxon_concept_id, MAX(annotations.symbol) AS symbol, MAX(annotations.parent_symbol) AS parent_symbol
      FROM listing_changes
      INNER JOIN annotations
        ON listing_changes.hash_annotation_id = annotations.id
      INNER JOIN change_types
        ON listing_changes.change_type_id = change_types.id
      INNER JOIN designations
        ON change_types.designation_id = designations.id AND designations.name = 'CITES'
      WHERE listing_changes.is_current = TRUE
      GROUP BY taxon_concept_id
    ) taxon_concept_hash_annotations
    WHERE
      taxon_concept_hash_annotations.taxon_concept_id = taxon_concepts.id AND
      CASE WHEN node_id IS NOT NULL THEN id = node_id ELSE TRUE END;

    END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_cites_annotation_symbols() RETURNS void
  LANGUAGE plpgsql
  AS $$
    BEGIN
    PERFORM rebuild_cites_annotation_symbols_for_node(NULL);
    PERFORM rebuild_cites_hash_annotation_symbols_for_node(NULL);
    END;
  $$;

COMMENT ON FUNCTION rebuild_cites_annotation_symbols() IS 'Procedure to rebuild generic and specific annotation symbols to be used in the CITES index pdf.';
