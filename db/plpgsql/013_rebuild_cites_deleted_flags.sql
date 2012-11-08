--
-- Name: rebuild_cites_deleted_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_deleted_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_id int;
          deletion_id int;
          tmp boolean;
          match_id int;
        BEGIN
        SELECT id INTO cites_id FROM designations WHERE name = 'CITES';
        SELECT id INTO deletion_id FROM change_types WHERE name = 'DELETION';

        -- set the cites_deleted flag to false for all taxa (so we start clear)
        UPDATE taxon_concepts SET listing = listing|| hstore('cites_deleted', 'f')
        WHERE designation_id = cites_id;

        select listing->'cites_deleted' into tmp from taxon_concepts where id=33;
        RAISE NOTICE '%', tmp;
SELECT INTO match_id taxon_concepts.id FROM
          taxon_concepts INNER JOIN listing_changes
          ON taxon_concepts.id = listing_changes.taxon_concept_id
            AND is_current = 't' AND change_type_id = deletion_id LIMIT 1;
        RAISE NOTICE '%', match_id;
        IF NOT FOUND THEN
        RAISE NOTICE 'no match';
        END IF;
        
        -- set the cites_deleted flag to true for taxa which are currently deleted
        WITH deleted_taxa AS(
          SELECT taxon_concepts.id FROM
          taxon_concepts INNER JOIN listing_changes
          ON taxon_concepts.id = listing_changes.taxon_concept_id
            AND is_current = 't' AND change_type_id = deletion_id
          WHERE designation_id = cites_id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_deleted', 't')
        WHERE taxon_concepts.id IN (SELECT id FROM deleted_taxa);


        select listing->'cites_deleted' into tmp from taxon_concepts where id=33;
        RAISE NOTICE '%', tmp;
 
        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_deleted_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_deleted_flags() IS 'Procedure to rebuild the cites_deleted flag in taxon_concepts.listing.'