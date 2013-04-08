--
-- Name: rebuild_descendant_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_descendant_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

          WITH RECURSIVE q AS (
            SELECT h, id,
            listing - ARRAY['cites_status', 'cites_status_original', 'cites_not_listed', 'cites_fully_covered'] ||
            hstore('cites_listing', -- listing->'cites_listing_original')
              CASE
                WHEN listing->'cites_not_listed' = 'NC'
                THEN listing->'cites_not_listed'
                WHEN listing->'cites_status' = 'LISTED'
                THEN listing->'cites_listing_original'
                ELSE NULL
              END
            ) || hstore('closest_listed_ancestor_id', h.id::VARCHAR)
            AS inherited_listing
            FROM taxon_concepts h
            WHERE listing->'cites_status_original' = 't'

            UNION ALL

            SELECT hi, hi.id,
            CASE
            WHEN
              hi.listing->'cites_status_original' = 't'
            THEN
              hstore('cites_listing',hi.listing->'cites_listing_original') ||
              slice(hi.listing, ARRAY['hash_ann_symbol', 'ann_symbol']) ||
              hstore('closest_listed_ancestor_id', hi.id::VARCHAR)
            ELSE
              inherited_listing
            END
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
          )
          UPDATE taxon_concepts
          SET
          closest_listed_ancestor_id = (q.inherited_listing->'closest_listed_ancestor_id')::INTEGER,
          listing = listing || q.inherited_listing - ARRAY['closest_listed_ancestor_id']
          FROM q
          WHERE taxon_concepts.id = q.id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_descendant_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_descendant_listings() IS 'Procedure to rebuild the computed descendant listings in taxon_concepts.';

