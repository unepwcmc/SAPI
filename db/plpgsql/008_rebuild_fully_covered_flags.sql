--
-- Name: rebuild_fully_covered_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_fully_covered_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_id int;
          exception_id int;
        BEGIN
        SELECT id INTO wildlife_trade_id FROM taxonomies WHERE name = 'WILDLIFE_TRADE';
        SELECT id INTO exception_id FROM change_types WHERE name = 'EXCEPTION';

        -- set the fully_covered flag to true for all taxa (so we start clear)
        UPDATE taxon_concepts SET listing = listing ||
          hstore('cites_fully_covered', 't')
        WHERE taxonomy_id = wildlife_trade_id;

        -- set the fully_covered flag to false for taxa with descendants who:
        -- * were deleted from the listing
        -- * were excluded from the listing
        WITH qq AS (
          WITH RECURSIVE q AS (
            SELECT h, id,
            CASE
              WHEN (listing->'cites_status')::VARCHAR = 'DELETED'
                OR (listing->'cites_status')::VARCHAR = 'EXCLUDED'
              THEN 't'
              ELSE 'f'
            END AS not_listed
            FROM taxon_concepts h
            WHERE taxonomy_id = wildlife_trade_id AND (
              listing->'cites_status' = 'DELETED' OR listing->'cites_status' = 'EXCLUDED'
            )

            UNION ALL

            SELECT hi, hi.id,
            CASE
              WHEN (listing->'cites_status')::VARCHAR = 'DELETED'
                OR (listing->'cites_status')::VARCHAR = 'EXCLUDED'
              THEN 't'
              ELSE not_listed
            END
            FROM taxon_concepts hi
            INNER JOIN    q
            ON      hi.id = (q.h).parent_id
          )
          SELECT id, BOOL_OR((not_listed)::BOOLEAN) AS not_fully_covered
          FROM q 
          GROUP BY id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_fully_covered', 'f')
        FROM qq
        WHERE taxon_concepts.id = qq.id AND qq.not_fully_covered = 't';

        -- set the fully_covered flag to false for taxa which only have some
        -- populations listed
        WITH incomplete_distributions AS (
          SELECT taxon_concept_id AS id
          FROM listing_distributions
          INNER JOIN listing_changes
            ON listing_changes.id = listing_distributions.listing_change_id
          INNER JOIN taxon_concepts
            ON taxon_concepts.id = listing_changes.taxon_concept_id
          WHERE is_current = 't' AND taxonomy_id = wildlife_trade_id
            AND NOT listing_distributions.is_party

          EXCEPT

          SELECT taxon_concept_id AS id FROM listing_distributions
          RIGHT JOIN listing_changes
            ON listing_changes.id = listing_distributions.listing_change_id
          INNER JOIN taxon_concepts
            ON taxon_concepts.id = listing_changes.taxon_concept_id
          WHERE is_current = 't' AND taxonomy_id = wildlife_trade_id
            AND listing_distributions.id IS NULL OR listing_distributions.is_party
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_fully_covered', 'f')
          || hstore('cites_NC', 'NC')
        FROM incomplete_distributions
        WHERE taxon_concepts.id = incomplete_distributions.id;

        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('cites_NC', 'NC')
        WHERE (listing->'cites_fully_covered')::BOOLEAN <> 't' OR (listing->'cites_status')::VARCHAR IS NULL;

        END;
      $$;


--
-- Name: FUNCTION rebuild_fully_covered_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_fully_covered_flags() IS 'Procedure to rebuild the fully_covered flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - all descendants are listed, "f" - some descendants were excluded or deleted from listing'