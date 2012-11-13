--
-- Name: rebuild_descendant_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_descendant_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

          WITH RECURSIVE q AS (
            SELECT h, id,
            listing - ARRAY['cites_listed'] ||
            hstore('current_listing', -- listing->'cites_listing_original')
              CASE
                WHEN listing->'cites_deleted' = 't' OR listing->'cites_excluded' = 't'
                THEN listing->'not_in_cites'
                WHEN listing->'cites_listed' = 't'
                THEN listing->'cites_listing_original'
                ELSE NULL
              END
            )
            AS inherited_listing
            FROM taxon_concepts h
            WHERE listing-> 'cites_listed' = 't' OR listing->'cites_deleted' = 't' OR listing->'cites_excluded' = 't'

            UNION ALL

            SELECT hi, hi.id,
            CASE
            WHEN
              hi.listing -> 'cites_listed' ='t' OR
                hi.listing->'cites_excluded' = 't' OR
                hi.listing->'cites_deleted' = 't'
            THEN
              hstore('current_listing',hi.listing->'cites_listing_original') ||
              slice(hi.listing, ARRAY['generic_annotation_symbol', 'specific_annotation_symbol'])
            ELSE
              inherited_listing
            END
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
          )
          UPDATE taxon_concepts
          SET listing = listing || q.inherited_listing
          FROM q
          WHERE taxon_concepts.id = q.id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_descendant_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_descendant_listings() IS 'Procedure to rebuild the computed descendant listings in taxon_concepts.';

