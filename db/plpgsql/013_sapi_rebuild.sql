CREATE OR REPLACE FUNCTION sapi_rebuild() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
          RAISE NOTICE 'Rebuilding SAPI database';
          PERFORM rebuild_taxonomy();
          PERFORM rebuild_cites_listing();
          PERFORM rebuild_eu_listing();
          PERFORM rebuild_cms_listing();
          PERFORM rebuild_cites_accepted_flags();
        END;
      $$;

COMMENT ON FUNCTION sapi_rebuild() IS 'Procedure to rebuild computed fields in the database.';
