--
-- Name: rebuild_cites_listed_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_listed_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        -- set the cites_listed flag to NULL for all taxa (so we start clear)
        UPDATE taxon_concepts SET listing =
          CASE
            WHEN listing IS NULL THEN ''::HSTORE
            ELSE listing - ARRAY['cites_listing','cites_I','cites_II','cites_III','not_in_cites']
          END || hstore('cites_listed', NULL);

        -- set the cited_listed flag to true for all explicitly listed taxa
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_listed', 't')
        FROM (
          SELECT taxon_concepts.id
          FROM taxon_concepts
          INNER JOIN listing_changes ON taxon_concept_id = taxon_concepts.id
        ) AS q
        WHERE taxon_concepts.id = q.id;

        -- set the cites_listed flag to false for all implicitly listed taxa
        WITH RECURSIVE q AS
        (
          SELECT  h,
          (listing->'cites_listed')::BOOLEAN AS inherited_cites_listing
          FROM    taxon_concepts h
          WHERE   parent_id IS NULL

          UNION ALL

          SELECT  hi,
          CASE
            WHEN (listing->'cites_listed')::BOOLEAN = 't' THEN 't'
            ELSE inherited_cites_listing
          END
          FROM    q
          JOIN    taxon_concepts hi
          ON      hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_listed', 'f')
        FROM q
        WHERE taxon_concepts.id = (q.h).id AND
          ((q.h).listing->'cites_listed')::BOOLEAN IS NULL AND
          q.inherited_cites_listing = 't';

        -- propagate the usr_cites_exclusion flag to all subtaxa
        -- unless they have cites_listed = 't'
        WITH RECURSIVE q AS (
          SELECT h
          FROM taxon_concepts h
          WHERE listing->'usr_cites_exclusion' = 't'

          UNION ALL

          SELECT hi
          FROM q
          JOIN taxon_concepts hi ON hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_exclusion', 't')
        FROM q
        WHERE taxon_concepts.id = (q.h).id;

        -- set flags for exceptions
        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC') || hstore('cites_listing_original', 'NC') || hstore('cites_show', 't')
        WHERE listing->'usr_cites_exclusion' = 't';

        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC') || hstore('cites_listing_original', 'NC')
        WHERE listing->'cites_exclusion' = 't';

        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('not_in_cites', 'NC')
        WHERE fully_covered <> 't' OR (listing->'cites_listed')::BOOLEAN IS NULL;

        -- set the cites_listed_children flags to true to all ancestors of taxa
        -- whose cites_listed IS NOT NULL
        -- this is used for the taxonomic layout
        WITH listed AS (
          WITH RECURSIVE q AS (
            SELECT h, ARRAY[]::INTEGER[] AS ancestors
            FROM taxon_concepts h
            WHERE parent_id IS NULL

            UNION ALL

            SELECT hi, ancestors || id
            FROM q
            JOIN taxon_concepts hi ON hi.parent_id = (q.h).id
          )
          SELECT (q.h).id, (q.h).data->'full_name', (q.h).data->'taxonomic_position', ancestors
          FROM q
          WHERE ((q.h).listing->'cites_listed')::BOOLEAN IS NOT NULL
        ) 
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_listed_children', 't')
        FROM (
          SELECT DISTINCT UNNEST(ancestors) AS ID
          FROM listed
        ) listed_ancestors
        WHERE listed_ancestors.id = taxon_concepts.id;
        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_listed_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_listed_flags() IS 'Procedure to rebuild the cites_listed flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - explicit cites listing, "f" - implicit cites listing, "" - N/A';