--
-- Name: rebuild_cites_excluded_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_excluded_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_id int;
        BEGIN
        SELECT id INTO cites_id FROM designations WHERE name = 'CITES';

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

        -- set flags for exceptions
        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC') || hstore('cites_listing_original', 'NC') || hstore('cites_show', 't')
        WHERE listing->'usr_cites_excluded' = 't';

        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC') || hstore('cites_listing_original', 'NC')
        WHERE listing->'cites_excluded' = 't';

        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC')
        WHERE (data->'cites_fully_covered')::BOOLEAN <> 't' OR (listing->'cites_listed')::BOOLEAN IS NULL;
 
        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_excluded_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_excluded_flags() IS 'Procedure to rebuild the cites_excluded flag in taxon_concepts.listing.'