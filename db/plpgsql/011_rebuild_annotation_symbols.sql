--
-- Name: rebuild_annotation_symbols(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_annotation_symbols() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        UPDATE annotations
        SET symbol = ordered_annotations.calculated_symbol
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

        UPDATE taxon_concepts
        SET listing = listing - ARRAY['ann_symbol', 'hash_ann_symbol', 'hash_ann_parent_symbol'];

        UPDATE taxon_concepts
        SET listing = listing || hstore('ann_symbol', taxon_concept_annotations.symbol)
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
        WHERE taxon_concept_annotations.taxon_concept_id = taxon_concepts.id;

        UPDATE taxon_concepts
        SET listing = listing ||
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
          WHERE is_current = TRUE
          GROUP BY taxon_concept_id
        ) taxon_concept_hash_annotations
        WHERE taxon_concept_hash_annotations.taxon_concept_id = taxon_concepts.id;

        END;
      $$;

--
-- Name: FUNCTION rebuild_annotation_symbols(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_annotation_symbols() IS 'Procedure to rebuild generic and specific annotation symbols to be used in the index pdf.';