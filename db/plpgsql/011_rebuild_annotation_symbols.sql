--
-- Name: rebuild_annotation_symbols(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_annotation_symbols() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
        -- start clear
        UPDATE taxon_concepts
        SET listing = listing - ARRAY['ann_symbol',
          'hash_ann_parent_symbol', 'hash_ann_symbol'];

        -- update specific annotation symbols
        -- need to put all taxa with specific annotations in alphabetical order (as in the index pdf)
        -- and use row numbers as annotation symbols
        WITH taxon_concepts_with_specific_symbols AS (
          WITH taxon_concepts_with_specific_annotations AS (
          SELECT taxon_concept_id, annotations.id AS annotation_id
          FROM 
          listing_changes
          INNER JOIN taxon_concepts ON listing_changes.taxon_concept_id = taxon_concepts.id
          INNER JOIN annotations ON listing_changes.annotation_id = annotations.id
            AND annotations.display_in_index = TRUE
          INNER JOIN change_types ON change_types.id = listing_changes.change_type_id
          INNER JOIN designations ON designations.id = change_types.designation_id
            AND designations.name = 'CITES'
          WHERE is_current = TRUE
          ORDER BY data->'kingdom_name', full_name
          )
          SELECT taxon_concept_id, ROW_NUMBER() OVER() AS specific_symbol
          FROM taxon_concepts_with_specific_annotations
          GROUP BY taxon_concept_id
        )
        UPDATE taxon_concepts SET listing = listing || hstore('ann_symbol', specific_symbol::VARCHAR)
        FROM taxon_concepts_with_specific_symbols
        WHERE taxon_concepts.id = taxon_concepts_with_specific_symbols.taxon_concept_id;

        -- update generic annotation symbols
        WITH taxon_concepts_with_generic_symbols AS (
          SELECT taxon_concept_id,
          MAX(annotations.symbol) AS generic_symbol,
          MAX(annotations.parent_symbol) AS generic_parent_symbol
          FROM
          listing_changes
          INNER JOIN annotations ON listing_changes.hash_annotation_id = annotations.id
          INNER JOIN change_types ON change_types.id = listing_changes.change_type_id
          INNER JOIN designations ON designations.id = change_types.designation_id
            AND designations.name = 'CITES'
          WHERE is_current = TRUE
          GROUP BY taxon_concept_id
        )
        UPDATE taxon_concepts SET listing = listing ||
          hstore('hash_ann_symbol', generic_symbol::VARCHAR) ||
          hstore('hash_ann_parent_symbol', generic_parent_symbol::VARCHAR)
        FROM taxon_concepts_with_generic_symbols
        WHERE taxon_concepts.id = taxon_concepts_with_generic_symbols.taxon_concept_id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_annotation_symbols(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_annotation_symbols() IS 'Procedure to rebuild generic and specific annotation symbols to be used in the index pdf.';