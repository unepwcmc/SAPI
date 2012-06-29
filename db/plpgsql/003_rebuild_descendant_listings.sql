--
-- Name: rebuild_descendant_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_descendant_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
          WITH RECURSIVE q AS (
            SELECT h, id, listing
            FROM taxon_concepts h
            WHERE parent_id IS NULL

            UNION ALL

            SELECT hi, hi.id, CASE
              WHEN
                CAST(hi.listing -> 'cites_listing' AS VARCHAR) IS NOT NULL
                OR hi.not_in_cites = 't'
                THEN hi.listing
              WHEN  hi.listing IS NOT NULL THEN hi.listing || q.listing
              ELSE q.listing
            END
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
          )
          UPDATE taxon_concepts
          SET listing = 
          CASE
            WHEN taxon_concepts.listing IS NULL THEN ''::hstore
            ELSE taxon_concepts.listing
          END || q.listing
          FROM q
          WHERE taxon_concepts.id = q.id;
        END;
      $$;


--
-- Name: FUNCTION rebuild_descendant_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_descendant_listings() IS 'Procedure to rebuild the computed descendant listings in taxon_concepts.';

