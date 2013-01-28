--
-- Name: rebuild_cites_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_status() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          wildlife_trade_id int;
          deletion_id int;
          addition_id int;
          exception_id int;
        BEGIN
        SELECT id INTO wildlife_trade_id FROM taxonomies WHERE name = 'WILDLIFE_TRADE';
        SELECT id INTO deletion_id FROM change_types WHERE name = 'DELETION';
        SELECT id INTO addition_id FROM change_types WHERE name = 'ADDITION';
        SELECT id INTO exception_id FROM change_types WHERE name = 'EXCEPTION';

        -- set the cites_status property to NULL for all taxa (so we start clear)
        UPDATE taxon_concepts SET listing =
          CASE
            WHEN listing IS NULL THEN ''::HSTORE
            ELSE listing - ARRAY['cites_listing','cites_I','cites_II','cites_III','cites_NC']
          END || hstore('cites_status', NULL) || hstore('cites_status_original', NULL) ||
            hstore('listing_updated_at', NULL)
        WHERE taxonomy_id = wildlife_trade_id;

        -- set cites_status property to 'LISTED' for all explicitly listed taxa
        -- i.e. ones which have at least one current ADDITION
        -- also set cites_status_original flag to true
        -- also set the listing_updated_at property
        WITH listed_taxa AS (
          SELECT taxon_concepts.id, MAX(effective_at) AS listing_updated_at
          FROM taxon_concepts
          INNER JOIN listing_changes
            ON taxon_concepts.id = listing_changes.taxon_concept_id
            AND is_current = 't' AND change_type_id = addition_id
          WHERE taxonomy_id = wildlife_trade_id
          GROUP BY taxon_concepts.id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_status', 'LISTED') ||
          hstore('cites_status_original', 't') ||
          hstore('listing_updated_at', listing_updated_at::VARCHAR)
        FROM listed_taxa
        WHERE taxon_concepts.id = listed_taxa.id;


        -- set cites_status property to 'DELETED' for all explicitly deleted taxa
        -- omit ones already marked as listed (applies to appendix III deletions)
        -- also set cites_status_original flag to true
        WITH deleted_taxa AS (
          SELECT taxon_concepts.id
          FROM taxon_concepts
          INNER JOIN listing_changes
            ON taxon_concepts.id = listing_changes.taxon_concept_id
            AND is_current = 't' AND change_type_id = deletion_id
          WHERE taxonomy_id = wildlife_trade_id AND (
            listing -> 'cites_status' <> 'LISTED'
              OR (listing -> 'cites_status')::VARCHAR IS NULL
          )
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_status', 'DELETED') ||
          hstore('cites_status_original', 't')
        FROM deleted_taxa
        WHERE taxon_concepts.id = deleted_taxa.id;

        -- set cites_status property to 'EXCLUDED' for all explicitly excluded taxa
        -- also set cites_status_original flag to true
        WITH excluded_taxa AS (
          WITH listing_exceptions AS (
            SELECT listing_changes.parent_id, taxon_concept_id
            FROM listing_changes
            INNER JOIN taxon_concepts
              ON listing_changes.taxon_concept_id  = taxon_concepts.id
                AND taxonomy_id = wildlife_trade_id
            WHERE change_type_id = exception_id
          )
          SELECT listing_exceptions.taxon_concept_id AS id
          FROM listing_exceptions
          INNER JOIN listing_changes
            ON listing_changes.id = listing_exceptions.parent_id
              AND listing_changes.taxon_concept_id <> listing_exceptions.taxon_concept_id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_status', 'EXCLUDED') ||
          hstore('cites_status_original', 't')
        FROM excluded_taxa
        WHERE taxon_concepts.id = excluded_taxa.id;

        -- propagate cites_status to descendants
        WITH RECURSIVE q AS
        (
          SELECT  h,
          listing->'cites_status' AS inherited_cites_status,
          listing->'listing_updated_at' AS inherited_listing_updated_at
          FROM    taxon_concepts h
          WHERE   (listing->'cites_status_original')::BOOLEAN = 't'

          UNION ALL

          SELECT  hi,
          inherited_cites_status,
          inherited_listing_updated_at
          FROM    q
          JOIN    taxon_concepts hi
          ON      hi.parent_id = (q.h).id
          WHERE (listing->'cites_status_original')::BOOLEAN IS NULL
            OR (listing->'cites_status_original')::BOOLEAN = 'f'
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_status', inherited_cites_status)
          || hstore('listing_updated_at', inherited_listing_updated_at) ||
          hstore('cites_status_original', 'f')
        FROM q
        WHERE taxon_concepts.id = (q.h).id AND (
        (listing->'cites_status_original')::BOOLEAN IS NULL
          OR (listing->'cites_status_original')::BOOLEAN = 'f'
        );

        -- set cites_status property to 'LISTED' for ancestors of listed taxa
        WITH qq AS (
          WITH RECURSIVE q AS
          (
            SELECT  h,
            listing->'cites_status' AS inherited_cites_status,
            (listing->'listing_updated_at')::TIMESTAMP AS inherited_listing_updated_at,
            h.id
            FROM    taxon_concepts h
            WHERE   listing->'cites_status' = 'LISTED'
              AND (listing->'cites_status_original')::BOOLEAN = 't'

            UNION ALL

            SELECT  hi,
            CASE
              WHEN (listing->'cites_status_original')::BOOLEAN = 't'
              THEN listing->'cites_status'
              ELSE inherited_cites_status
            END,
            CASE
              WHEN (listing->'listing_updated_at')::TIMESTAMP IS NOT NULL
              THEN (listing->'listing_updated_at')::TIMESTAMP
              ELSE inherited_listing_updated_at
            END,
            hi.id
            FROM    q
            JOIN    taxon_concepts hi
            ON      hi.id = (q.h).parent_id
            WHERE (listing->'cites_status_original')::BOOLEAN IS NULL
          )
          SELECT DISTINCT id, inherited_cites_status, 
            inherited_listing_updated_at
          FROM q
        )
        UPDATE taxon_concepts
        SET listing = listing ||
          hstore('cites_status', inherited_cites_status) ||
          hstore('cites_status_original', 'f') ||
          hstore('listing_updated_at', inherited_listing_updated_at::VARCHAR)
        FROM qq
        WHERE taxon_concepts.id = qq.id
         AND (
           (listing->'cites_status_original')::BOOLEAN IS NULL
             OR (listing->'cites_status_original')::BOOLEAN = 'f'
         );

        -- set the cites_status_original flag to false for taxa included in parent listing
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_status_original', 'f')
        FROM
        listing_changes
        WHERE
        taxon_concepts.id = listing_changes.taxon_concept_id
        AND is_current = 't'
        AND inclusion_taxon_concept_id IS NOT NULL;

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_status(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_status() IS 'Procedure to rebuild the cites_status flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - explicit cites listing, "f" - implicit cites listing, "" - N/A';