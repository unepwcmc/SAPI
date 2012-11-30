--
-- Name: rebuild_cites_nc_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_nc_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_id int;
          exception_id int;
        BEGIN

        -- set nc flags for all unlisted taxa
        UPDATE taxon_concepts
        SET listing = listing ||
        hstore('cites_nc', 'NC') || hstore('cites_listing_original', 'NC')
        WHERE (listing->'cites_status')::VARCHAR = 'DELETED'
          OR (listing->'cites_status')::VARCHAR = 'EXCLUDED';

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_nc_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_nc_flags() IS 'Procedure to rebuild the cites_nc flag in taxon_concepts.listing.'