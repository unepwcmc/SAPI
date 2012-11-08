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

            SELECT hi, hi.id,
            CASE
            WHEN
              hi.listing -> 'cites_listed' ='t' OR
                hi.listing->'cites_excluded' = 't'
            THEN hi.listing || hstore('cites_listing',hi.listing->'cites_listing_original') ||
              slice(hi.listing, ARRAY['generic_annotation_symbol', 'specific_annotation_symbol'])
            ELSE hi.listing ||
              (q.listing::hstore - ARRAY['cites_listed','cites_listing_original']) ||
              hstore('cites_listing',q.listing->'cites_listing_original') ||
              slice(q.listing, ARRAY['generic_annotation_symbol', 'specific_annotation_symbol'])
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

