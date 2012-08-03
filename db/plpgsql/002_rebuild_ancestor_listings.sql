--
-- Name: rebuild_ancestor_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_ancestor_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
          WITH qq AS (
            WITH RECURSIVE q AS (
              SELECT h, id, listing
              FROM taxon_concepts h

              UNION ALL

              SELECT hi, hi.id,
              CASE 
                WHEN hi.listing IS NULL THEN q.listing
                ELSE hi.listing || q.listing
              END
              FROM taxon_concepts hi
              INNER JOIN    q
              ON      hi.id = (q.h).parent_id
            )
            SELECT id,
            hstore('cites_I', MAX((listing -> 'cites_I')::VARCHAR)) ||
            hstore('cites_II', MAX((listing -> 'cites_II')::VARCHAR)) ||
            hstore('cites_III', MAX((listing -> 'cites_III')::VARCHAR)) ||
            hstore('not_in_cites', MAX((listing -> 'not_in_cites')::VARCHAR)) ||
            hstore('cites_listing', ARRAY_TO_STRING(
              -- unnest to filter out the nulls
              ARRAY(SELECT * FROM UNNEST(
                ARRAY[
                  MAX((listing -> 'cites_I')::VARCHAR),
                  MAX((listing -> 'cites_II')::VARCHAR),
                  MAX((listing -> 'cites_III')::VARCHAR),
                  MAX((listing -> 'not_in_cites')::VARCHAR)
                ]) s WHERE s IS NOT NULL),
                '/'
              )
            ) AS listing
            FROM q 
            GROUP BY (id)
          )
          UPDATE taxon_concepts
          SET listing = 
            CASE
            WHEN taxon_concepts.listing IS NOT NULL THEN taxon_concepts.listing
            ELSE ''::hstore
            END || qq.listing
          FROM qq
          WHERE taxon_concepts.id = qq.id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_ancestor_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_ancestor_listings() IS 'Procedure to rebuild the computed ancestor listings in taxon_concepts.';
