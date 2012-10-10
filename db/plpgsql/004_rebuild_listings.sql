--
-- Name: rebuild_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        PERFORM fix_cites_listing_changes();

        UPDATE taxon_concepts
        SET listing = taxon_concepts.listing || qqq.listing
        FROM (
          SELECT taxon_concept_id, listing ||
          hstore('cites_listing_original', ARRAY_TO_STRING(
            -- unnest to filter out the nulls
            ARRAY(SELECT * FROM UNNEST(
              ARRAY[listing -> 'cites_I', listing -> 'cites_II', listing -> 'cites_III']) s 
              WHERE s IS NOT NULL),
              '/'
            )
          ) AS listing
          FROM (
            SELECT taxon_concept_id, 
              hstore('cites_I', CASE WHEN SUM(cites_I) > 0 THEN 'I' ELSE NULL END) ||
              hstore('cites_II', CASE WHEN SUM(cites_II) > 0 THEN 'II' ELSE NULL END) ||
              hstore('cites_III', CASE WHEN SUM(cites_III) > 0 THEN 'III' ELSE NULL END) ||
              hstore('cites_del', CASE WHEN SUM(cites_del) > 0 THEN 't' ELSE 'f' END)
              AS listing
            FROM (
              SELECT taxon_concept_id, effective_at, species_listings.abbreviation, change_types.name AS change_type,
              CASE
                WHEN species_listings.abbreviation = 'I' AND change_types.name = 'ADDITION' THEN 1
                WHEN (species_listings.abbreviation = 'I' OR species_listing_id IS NULL)
                  AND change_types.name = 'DELETION' THEN -1
                ELSE 0
              END AS cites_I,
              CASE
                WHEN species_listings.abbreviation = 'II' AND change_types.name = 'ADDITION' THEN 1
                WHEN (species_listings.abbreviation = 'II' OR species_listing_id IS NULL)
                  AND change_types.name = 'DELETION' THEN -1
                ELSE 0
              END AS cites_II,
              CASE
                WHEN species_listings.abbreviation = 'III' AND change_types.name = 'ADDITION' THEN 1
                WHEN (species_listings.abbreviation = 'III' OR species_listing_id IS NULL)
                  AND change_types.name = 'DELETION' THEN -1
                ELSE 0
              END AS cites_III,
              CASE
                WHEN species_listing_id IS NULL AND change_types.name = 'DELETION' THEN 1
                ELSE 0
              END AS cites_del
              FROM listing_changes 

              LEFT JOIN change_types ON change_type_id = change_types.id
              AND change_types.name IN ('ADDITION','DELETION')
              AND effective_at <= NOW()
              LEFT JOIN species_listings ON species_listing_id = species_listings.id
              LEFT JOIN taxon_concepts ON taxon_concept_id = taxon_concepts.id
              LEFT JOIN designations ON taxon_concepts.designation_id = designations.id
              WHERE designations.name = 'CITES'
              AND is_current = 't' 
            ) AS q
            GROUP BY taxon_concept_id
          ) AS qq
        ) AS qqq
        WHERE taxon_concepts.id = qqq.taxon_concept_id;

        -- set cites_show to false for all deleted taxa
        UPDATE taxon_concepts SET listing = listing || hstore('cites_show', 'f')
        WHERE (listing->'cites_del')::BOOLEAN = 't';
        END;
      $$;


--
-- Name: FUNCTION rebuild_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_listings() IS 'Procedure to rebuild the computed listings in taxon_concepts.';
