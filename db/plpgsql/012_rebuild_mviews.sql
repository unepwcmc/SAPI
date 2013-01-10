--
-- Name: rebuild_mviews(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_mviews() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
          RAISE NOTICE 'Dropping materialized views';
          DROP table listing_changes_mview;
          DROP table taxon_concepts_mview;

          RAISE NOTICE 'Creating materialized views';
          CREATE TABLE listing_changes_mview AS
          SELECT *,
          false as dirty,
          null::timestamp with time zone as expiry
          FROM listing_changes_view;

          CREATE TABLE taxon_concepts_mview AS
          SELECT *,
          false as dirty,
          null::timestamp with time zone as expiry
          FROM taxon_concepts_view;
        END;
      $$;


--
-- Name: FUNCTION rebuild_mviews(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_mviews() IS 'Procedure to rebuild materialized views in the database.';
