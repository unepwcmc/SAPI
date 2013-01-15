--
-- Name: rebuild_annotation_symbols(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_annotation_symbols() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
        -- start clear
        UPDATE taxon_concepts
        SET listing = listing - ARRAY['specific_annotation_symbol',
          'generic_annotation_parent_symbol', 'generic_annotation_symbol'];

        -- update specific annotation symbols
        -- need to put all taxa with specific annotations in alphabetical order (as in the index pdf)
        -- and use row numbers as annotation symbols
        WITH taxon_concepts_with_specific_symbols AS (
          WITH taxon_concepts_with_specific_annotations AS (
          -- need to find addition records, which have exceptions or that have distributions attached
          SELECT taxon_concept_id, annotations.id AS annotation_id
          FROM 
          annotations
          INNER JOIN listing_changes ON annotations.listing_change_id = listing_changes.id
          INNER JOIN change_types ON change_types.id = listing_changes.change_type_id AND change_types.name = 'ADDITION'
          INNER JOIN taxon_concepts ON listing_changes.taxon_concept_id = taxon_concepts.id
          INNER JOIN designations ON designations.id = taxon_concepts.designation_id AND designations.name = 'CITES'
          WHERE is_current = 't'
            AND EXISTS (
                SELECT * FROM listing_changes listing_changes_exceptions
                WHERE listing_changes.id = listing_changes_exceptions.parent_id
              )
            OR EXISTS (
                SELECT * FROM listing_distributions
                WHERE listing_changes.id = listing_distributions.listing_change_id AND is_party = 'f'
              )
          ORDER BY data->'kingdom_name', full_name
          )
          SELECT taxon_concept_id, ROW_NUMBER() OVER() AS specific_symbol
          FROM taxon_concepts_with_specific_annotations
          GROUP BY taxon_concept_id
        )
        UPDATE taxon_concepts SET listing = listing || hstore('specific_annotation_symbol', specific_symbol::VARCHAR)
        FROM taxon_concepts_with_specific_symbols
        WHERE taxon_concepts.id = taxon_concepts_with_specific_symbols.taxon_concept_id;

        -- update generic annotation symbols
        WITH taxon_concepts_with_generic_symbols AS (
                SELECT taxon_concept_id,
                MAX(annotations.symbol) AS generic_symbol,
                MAX(annotations.parent_symbol) AS generic_parent_symbol
                FROM 
                taxon_concepts
                LEFT JOIN designations ON designations.id = taxon_concepts.designation_id
                LEFT JOIN listing_changes ON listing_changes.taxon_concept_id = taxon_concepts.id
                LEFT JOIN change_types ON change_types.id = listing_changes.change_type_id
                INNER JOIN annotations ON listing_changes.annotation_id = annotations.id
                WHERE designations.name = 'CITES' AND is_current = 't'
                  AND change_types.name = 'ADDITION'
                GROUP BY taxon_concept_id
        )
        UPDATE taxon_concepts SET listing = listing ||
          hstore('generic_annotation_symbol', generic_symbol::VARCHAR) ||
          hstore('generic_annotation_parent_symbol', generic_parent_symbol::VARCHAR)
        FROM taxon_concepts_with_generic_symbols
        WHERE taxon_concepts.id = taxon_concepts_with_generic_symbols.taxon_concept_id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_annotation_symbols(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_annotation_symbols() IS 'Procedure to rebuild generic and specific annotation symbols to be used in the index pdf.';