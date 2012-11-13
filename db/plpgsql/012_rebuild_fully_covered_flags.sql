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
        SELECT id INTO cites_id FROM designations WHERE name = 'CITES';
        SELECT id INTO exception_id FROM change_types WHERE name = 'EXCEPTION';

        -- set the fully_covered flag to true for all taxa (so we start clear)
        UPDATE taxon_concepts SET listing = listing ||
          hstore('cites_fully_covered', 't')
        WHERE designation_id = cites_id;

        -- set the fully_covered flag to false for taxa with descendants who:
        -- * were deleted from the listing
        -- * were excluded from the listing
        WITH qq AS (
          WITH RECURSIVE q AS (
            SELECT h, id,
              (listing->'cites_deleted')::BOOLEAN AS cites_deleted,
              (listing->'cites_excluded')::BOOLEAN AS cites_excluded
            FROM taxon_concepts h
            WHERE designation_id = cites_id AND (
              listing->'cites_deleted' = 't' OR listing->'cites_excluded' = 't'
            )

            UNION ALL

            SELECT hi, hi.id,
              (listing->'cites_deleted')::BOOLEAN = 't' OR cites_deleted,
              (listing->'cites_excluded')::BOOLEAN = 't' OR cites_excluded
            FROM taxon_concepts hi
            INNER JOIN    q
            ON      hi.id = (q.h).parent_id
          )
          SELECT id, BOOL_OR(
            cites_deleted AND cites_deleted IS NOT NULL
            OR
            cites_excluded AND cites_excluded IS NOT NULL
          ) AS not_fully_covered
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
          WHERE is_current = 't' AND designation_id = cites_id
            AND NOT listing_distributions.is_party

          EXCEPT

          SELECT taxon_concept_id AS id FROM listing_distributions
          RIGHT JOIN listing_changes
            ON listing_changes.id = listing_distributions.listing_change_id
          INNER JOIN taxon_concepts
            ON taxon_concepts.id = listing_changes.taxon_concept_id
          WHERE is_current = 't' AND designation_id = cites_id
            AND listing_distributions.id IS NULL OR listing_distributions.is_party
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_fully_covered', 'f')
          || hstore('not_in_cites', 'NC')
        FROM incomplete_distributions
        WHERE taxon_concepts.id = incomplete_distributions.id;

        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC')
        WHERE (listing->'cites_fully_covered')::BOOLEAN <> 't' OR (listing->'cites_listed')::BOOLEAN IS NULL;

        END;
      $$;


--
-- Name: FUNCTION rebuild_fully_covered_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_fully_covered_flags() IS 'Procedure to rebuild the fully_covered flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - all descendants are listed, "f" - some descendants were excluded or deleted from listing'