--
-- Name: rebuild_cites_deleted_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_cites_deleted_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_id int;
          deletion_id int;
          addition_id int;
        BEGIN
        SELECT id INTO cites_id FROM designations WHERE name = 'CITES';
        SELECT id INTO deletion_id FROM change_types WHERE name = 'DELETION';
        SELECT id INTO addition_id FROM change_types WHERE name = 'ADDITION';

        -- set the cites_deleted flag to false for all taxa (so we start clear)
        UPDATE taxon_concepts SET listing = listing|| hstore('cites_deleted', 'f')
        WHERE designation_id = cites_id;

        -- set the cites_deleted flag to true for appendix taxa,
        -- which are currently deleted and don't have active additions (app III)
        WITH deleted_taxa AS(
          SELECT taxon_concepts.id
          FROM taxon_concepts
          INNER JOIN listing_changes
            ON taxon_concepts.id = listing_changes.taxon_concept_id
            AND is_current = 't' AND change_type_id = deletion_id
          WHERE designation_id = cites_id

          EXCEPT

          SELECT taxon_concepts.id
          FROM taxon_concepts
          INNER JOIN listing_changes
            ON taxon_concepts.id = listing_changes.taxon_concept_id
            AND is_current = 't' AND change_type_id = addition_id
          WHERE designation_id = cites_id
        )
        UPDATE taxon_concepts
        SET listing = listing || hstore('cites_deleted', 't') ||
          hstore('not_in_cites', 'NC')
        FROM deleted_taxa
        WHERE taxon_concepts.id = deleted_taxa.id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_deleted_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_deleted_flags() IS 'Procedure to rebuild the cites_deleted flag in taxon_concepts.listing.'