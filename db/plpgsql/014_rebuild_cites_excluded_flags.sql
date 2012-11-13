--
-- Name: rebuild_cites_excluded_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_excluded_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_id int;
          exception_id int;
        BEGIN
        SELECT id INTO cites_id FROM designations WHERE name = 'CITES';
        SELECT id INTO exception_id FROM change_types WHERE name = 'EXCEPTION';

        -- set the cites_excluded flag to false for all taxa (so we start clear)
        UPDATE taxon_concepts SET listing = listing || hstore('cites_excluded', 'f')
        WHERE designation_id = cites_id;

        -- propagate the usr_cites_excluded flag to all subtaxa
        -- unless they have cites_listed = 't'
        WITH RECURSIVE q AS (
          SELECT h
          FROM taxon_concepts h
          WHERE listing->'usr_cites_excluded' = 't'

          UNION ALL

          SELECT hi
          FROM q
          JOIN taxon_concepts hi ON hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_excluded', 't')
        FROM q
        WHERE taxon_concepts.id = (q.h).id;

        -- set the cites_excluded flag to true for taxa, which are mentioned
        -- in taxonomic listing exceptions (i.e. 'EXCEPTION' records, where
        -- taxon_concept_id != parent record's taxon_concept_id
        WITH taxonomic_listing_exceptions AS (
          WITH listing_exceptions AS (
            SELECT listing_changes.parent_id, taxon_concept_id
            FROM listing_changes
            INNER JOIN taxon_concepts
              ON listing_changes.taxon_concept_id  = taxon_concepts.id
                AND designation_id = cites_id
            WHERE change_type_id = exception_id
          )
          SELECT listing_exceptions.taxon_concept_id AS id
          FROM listing_exceptions
          INNER JOIN listing_changes
            ON listing_changes.id = listing_exceptions.parent_id
              AND listing_changes.taxon_concept_id <> listing_exceptions.taxon_concept_id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_excluded', 't')
        FROM taxonomic_listing_exceptions
        WHERE taxon_concepts.id = taxonomic_listing_exceptions.id;

        -- set flags for exceptions
        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC') || hstore('cites_listing_original', 'NC')
          || hstore('cites_show', 't')
        WHERE listing->'usr_cites_excluded' = 't';

        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC') || hstore('cites_listing_original', 'NC')
          || hstore('cites_listed', 'f')
        WHERE listing->'cites_excluded' = 't';

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_excluded_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_excluded_flags() IS 'Procedure to rebuild the cites_excluded flag in taxon_concepts.listing.'