--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: binary_upgrade; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA binary_upgrade;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


SET search_path = binary_upgrade, pg_catalog;

--
-- Name: create_empty_extension(text, text, boolean, text, oid[], text[], text[]); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION create_empty_extension(text, text, boolean, text, oid[], text[], text[]) RETURNS void
    LANGUAGE c
    AS '$libdir/pg_upgrade_support', 'create_empty_extension';


--
-- Name: set_next_array_pg_type_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_array_pg_type_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_array_pg_type_oid';


--
-- Name: set_next_heap_pg_class_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_heap_pg_class_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_heap_pg_class_oid';


--
-- Name: set_next_index_pg_class_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_index_pg_class_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_index_pg_class_oid';


--
-- Name: set_next_pg_authid_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_pg_authid_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_pg_authid_oid';


--
-- Name: set_next_pg_enum_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_pg_enum_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_pg_enum_oid';


--
-- Name: set_next_pg_type_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_pg_type_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_pg_type_oid';


--
-- Name: set_next_toast_pg_class_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_toast_pg_class_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_toast_pg_class_oid';


--
-- Name: set_next_toast_pg_type_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_toast_pg_type_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_toast_pg_type_oid';


SET search_path = public, pg_catalog;

--
-- Name: ancestors_data(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ancestors_data(node_id integer) RETURNS hstore
    LANGUAGE plpgsql
    AS $$
  DECLARE
    result HSTORE;
    ancestor_row RECORD;
  BEGIN
    result := ''::HSTORE;
    FOR ancestor_row IN 
      WITH RECURSIVE q AS (
        SELECT h.id, h.parent_id, ranks.name AS rank_name, taxon_names.scientific_name AS scientific_name
        FROM taxon_concepts h
        INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
        INNER JOIN ranks ON h.rank_id = ranks.id
        WHERE h.id = node_id

        UNION

        SELECT hi.id, hi.parent_id, ranks.name, taxon_names.scientific_name

        FROM q
        JOIN taxon_concepts hi
        ON hi.id = q.parent_id
        INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
        INNER JOIN ranks ON hi.rank_id = ranks.id
      )
      SELECT 
      id, rank_name, scientific_name
      FROM q
    LOOP
      result := result ||
        HSTORE(LOWER(ancestor_row.rank_name) || '_name', ancestor_row.scientific_name) ||
        HSTORE(LOWER(ancestor_row.rank_name) || '_id', ancestor_row.id::VARCHAR);
    END LOOP;
    RETURN result;
  END;
  $$;


--
-- Name: full_name(character varying, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION full_name(rank_name character varying, ancestors hstore) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN CASE
      WHEN rank_name = 'SPECIES' THEN
        -- now create a binomen for full name
        CAST(ancestors -> 'genus_name' AS VARCHAR) || ' ' ||
        LOWER(CAST(ancestors -> 'species_name' AS VARCHAR))
      WHEN rank_name = 'SUBSPECIES' THEN
        -- now create a trinomen for full name
        CAST(ancestors -> 'genus_name' AS VARCHAR) || ' ' ||
        LOWER(CAST(ancestors -> 'species_name' AS VARCHAR)) || ' ' ||
        LOWER(CAST(ancestors -> 'subspecies_name' AS VARCHAR))
      ELSE ancestors -> LOWER(rank_name || '_name')
    END;
  END;
  $$;


--
-- Name: listing_changes_invalidate_row(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION listing_changes_invalidate_row(row_id integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE listing_changes_mview lc
  SET dirty = TRUE
  WHERE lc.id = row_id;
  RETURN;
END
$$;


--
-- Name: listing_changes_refresh_row(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION listing_changes_refresh_row(row_id integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  DELETE
  FROM listing_changes_mview lc
  WHERE lc.id = row_id;

  INSERT INTO listing_changes_mview
  SELECT *, FALSE, NULL
  FROM listing_changes_view lc
  WHERE lc.id = row_id;
END
$$;


--
-- Name: rebuild_ancestor_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_ancestor_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
          WITH qq AS (
            WITH RECURSIVE q AS (
              SELECT h, id, listing
              FROM taxon_concepts h

              UNION ALL

              SELECT hi, hi.id,
              CASE 
                WHEN hi.listing IS NULL THEN q.listing
                ELSE hi.listing || q.listing
              END
              FROM taxon_concepts hi
              INNER JOIN    q
              ON      hi.id = (q.h).parent_id
            )
            SELECT id,
            hstore('cites_I', MAX((listing -> 'cites_I')::VARCHAR)) ||
            hstore('cites_II', MAX((listing -> 'cites_II')::VARCHAR)) ||
            hstore('cites_III', MAX((listing -> 'cites_III')::VARCHAR)) ||
            hstore('cites_NC', MAX((listing -> 'cites_NC')::VARCHAR)) ||
            hstore('cites_listing', ARRAY_TO_STRING(
              -- unnest to filter out the nulls
              ARRAY(SELECT * FROM UNNEST(
                ARRAY[
                  MAX((listing -> 'cites_I')::VARCHAR),
                  MAX((listing -> 'cites_II')::VARCHAR),
                  MAX((listing -> 'cites_III')::VARCHAR),
                  MAX((listing -> 'cites_NC')::VARCHAR)
                ]) s WHERE s IS NOT NULL),
                '/'
              )
            ) AS listing
            FROM q 
            GROUP BY (id)
          )
          UPDATE taxon_concepts
          SET listing = taxon_concepts.listing || (qq.listing - 'cites_status'::VARCHAR)
          FROM qq
          WHERE taxon_concepts.id = qq.id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_ancestor_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_ancestor_listings() IS 'Procedure to rebuild the computed ancestor listings in taxon_concepts.';


--
-- Name: rebuild_annotation_symbols(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_annotation_symbols() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        UPDATE annotations
        SET symbol = ordered_annotations.calculated_symbol
        FROM
        (
          SELECT ROW_NUMBER() OVER(ORDER BY kingdom_position, full_name) AS calculated_symbol, MAX(annotations.id) AS id
          FROM listing_changes
          INNER JOIN annotations
            ON listing_changes.annotation_id = annotations.id
          INNER JOIN change_types
            ON listing_changes.change_type_id = change_types.id
          INNER JOIN designations
            ON change_types.designation_id = designations.id AND designations.name = 'CITES'
          INNER JOIN taxon_concepts_mview
            ON listing_changes.taxon_concept_id = taxon_concepts_mview.id
          WHERE is_current = TRUE AND display_in_index = TRUE
          GROUP BY taxon_concept_id, kingdom_position, full_name
          ORDER BY kingdom_position, full_name
        ) ordered_annotations
        WHERE ordered_annotations.id = annotations.id;

        UPDATE taxon_concepts
        SET listing = listing - ARRAY['ann_symbol', 'hash_ann_symbol', 'hash_ann_parent_symbol'];

        UPDATE taxon_concepts
        SET listing = listing || hstore('ann_symbol', taxon_concept_annotations.symbol)
        FROM
        (
          SELECT taxon_concept_id, MAX(annotations.symbol) AS symbol
          FROM listing_changes
          INNER JOIN annotations
            ON listing_changes.annotation_id = annotations.id
          INNER JOIN change_types
            ON listing_changes.change_type_id = change_types.id
          INNER JOIN designations
            ON change_types.designation_id = designations.id AND designations.name = 'CITES'
          WHERE is_current = TRUE AND display_in_index = TRUE
          GROUP BY taxon_concept_id
        ) taxon_concept_annotations
        WHERE taxon_concept_annotations.taxon_concept_id = taxon_concepts.id;

        UPDATE taxon_concepts
        SET listing = listing ||
          hstore('hash_ann_symbol', taxon_concept_hash_annotations.symbol) ||
          hstore('hash_ann_parent_symbol', taxon_concept_hash_annotations.parent_symbol)
        FROM
        (
          SELECT taxon_concept_id, MAX(annotations.symbol) AS symbol, MAX(annotations.parent_symbol) AS parent_symbol
          FROM listing_changes
          INNER JOIN annotations
            ON listing_changes.hash_annotation_id = annotations.id
          INNER JOIN change_types
            ON listing_changes.change_type_id = change_types.id
          INNER JOIN designations
            ON change_types.designation_id = designations.id AND designations.name = 'CITES'
          WHERE is_current = TRUE
          GROUP BY taxon_concept_id
        ) taxon_concept_hash_annotations
        WHERE taxon_concept_hash_annotations.taxon_concept_id = taxon_concepts.id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_annotation_symbols(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_annotation_symbols() IS 'Procedure to rebuild generic and specific annotation symbols to be used in the index pdf.';


--
-- Name: rebuild_cites_accepted_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_accepted_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        -- set the cites_accepted flag to null for all taxa (so we start clear)
        UPDATE taxon_concepts SET data =
          CASE
            WHEN data IS NULL THEN ''::HSTORE
            ELSE data
          END || hstore('cites_accepted', NULL);

        -- set the cites_accepted flag to true for all explicitly referenced taxa
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', 't')
        FROM (
          SELECT taxon_concepts.id
          FROM taxon_concepts
          INNER JOIN taxon_concept_references
            ON taxon_concept_references.taxon_concept_id = taxon_concepts.id
          INNER JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
          WHERE taxonomies.name = 'CITES_EU' AND (taxon_concept_references.data->'usr_is_std_ref')::BOOLEAN = 't'
        ) AS q
        WHERE taxon_concepts.id = q.id;

        -- set the cites_accepted flag to false for all synonyms
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', 'f')
        FROM (
          SELECT taxon_relationships.other_taxon_concept_id AS id
          FROM taxon_relationships
          INNER JOIN taxon_relationship_types
            ON taxon_relationship_types.id =
              taxon_relationships.taxon_relationship_type_id
          INNER JOIN taxon_concepts
            ON taxon_concepts.id = taxon_relationships.other_taxon_concept_id
          INNER JOIN taxonomies
            ON taxonomies.id = taxon_concepts.taxonomy_id
          WHERE taxonomies.name = 'CITES_EU'
            AND taxon_relationship_types.name = 'HAS_SYNONYM'
        ) AS q
        WHERE taxon_concepts.id = q.id;

        -- set the usr_no_std_ref for exclusions
        UPDATE taxon_concepts
        SET data = data || hstore('usr_no_std_ref', 't')
        FROM (
          WITH RECURSIVE cascading_refs AS (
            SELECT h, h.id, (taxon_concept_references.data->'exclusions')::INTEGER[] AS exclusions, false AS i_am_excluded
            FROM taxon_concept_references
            INNER JOIN taxon_concepts h
              ON h.id = taxon_concept_references.taxon_concept_id
            WHERE (taxon_concept_references.data->'cascade')::BOOLEAN
  
            UNION ALL
  
            SELECT hi, hi.id, exclusions, exclusions @> ARRAY[hi.id]
            FROM cascading_refs
            JOIN taxon_concepts hi
            ON hi.parent_id = (cascading_refs.h).id
          )
          SELECT id, BOOL_AND(i_am_excluded) AS i_am_excluded --excluded from all parent refs
          FROM cascading_refs
          GROUP BY id
        ) AS q
        WHERE taxon_concepts.id = q.id AND i_am_excluded;

        -- set the cites_accepted flag to true for all implicitly referenced taxa
        WITH RECURSIVE q AS
        (
          SELECT  h,
            CASE
              WHEN (h.data->'usr_no_std_ref')::BOOLEAN = 't' THEN 'f'
              ELSE (h.data->'cites_accepted')::BOOLEAN
            END AS inherited_cites_accepted
          FROM taxon_concept_references
          INNER JOIN taxon_concepts h
            ON h.id = taxon_concept_references.taxon_concept_id
          WHERE (taxon_concept_references.data->'cascade')::BOOLEAN

          UNION ALL

          SELECT  hi,
          CASE
            WHEN (data->'cites_accepted')::BOOLEAN = 't' THEN 't'
            WHEN (data->'usr_no_std_ref')::BOOLEAN = 't' THEN 'f'
            ELSE inherited_cites_accepted
          END
          FROM    q
          JOIN    taxon_concepts hi
          ON      hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', (q.inherited_cites_accepted)::VARCHAR)
        FROM q
        WHERE taxon_concepts.id = (q.h).id AND
          ((q.h).data->'cites_accepted')::BOOLEAN IS NULL;

        -- set the cites_accepted flag to false where it is not set
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', 'f')
        WHERE (data->'cites_accepted')::BOOLEAN IS NULL;

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_accepted_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_accepted_flags() IS 'Procedure to rebuild the cites_accepted flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - CITES accepted name, "f" - not accepted, but shows in Checklist, null - not accepted, doesn''t show';


--
-- Name: rebuild_cites_nc_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_nc_flags() RETURNS void
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

COMMENT ON FUNCTION rebuild_cites_nc_flags() IS 'Procedure to rebuild the cites_nc flag in taxon_concepts.listing.';


--
-- Name: rebuild_cites_show_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_show_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_eu_id int;
        BEGIN
        SELECT id INTO cites_eu_id FROM taxonomies WHERE name = 'CITES_EU';

        -- set cites_show to true for all taxa except:
        -- implicitly listed subspecies
        -- species of the family Orchidaceae
        -- deleted taxa
        -- excluded taxa
        UPDATE taxon_concepts SET listing = listing || 
        CASE
          WHEN (data->'rank_name' = 'SUBSPECIES'
          OR data->'rank_name' = 'CLASS'
          OR data->'rank_name' = 'PHYLUM'
          OR data->'rank_name' = 'KINGDOM')
          AND listing->'cites_status' = 'LISTED'
          THEN hstore('cites_show', 'f')
          WHEN data->'rank_name' <> 'FAMILY'
          AND data->'family_name' = 'Orchidaceae'
          THEN hstore('cites_show', 'f')
          WHEN listing->'cites_status' = 'DELETED' OR listing->'cites_status' = 'EXCLUDED'
          THEN hstore('cites_show', 'f')
          ELSE hstore('cites_show', 't')
        END
        WHERE taxonomy_id = cites_eu_id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_show_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_show_flags() IS 'Procedure to rebuild the cites_show flag in taxon_concepts.listing.';


--
-- Name: rebuild_cites_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_status() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_eu_id int;
          deletion_id int;
          addition_id int;
          exception_id int;
        BEGIN
        SELECT id INTO cites_eu_id FROM taxonomies WHERE name = 'CITES_EU';
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
        WHERE taxonomy_id = cites_eu_id;

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
          WHERE taxonomy_id = cites_eu_id
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
          WHERE taxonomy_id = cites_eu_id AND (
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
                AND taxonomy_id = cites_eu_id
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


--
-- Name: rebuild_descendant_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_descendant_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

          WITH RECURSIVE q AS (
            SELECT h, id,
            listing - ARRAY['cites_status', 'cites_status_original', 'cites_NC', 'cites_fully_covered'] ||
            hstore('cites_listing', -- listing->'cites_listing_original')
              CASE
                WHEN listing->'cites_NC' = 'NC'
                THEN listing->'cites_NC'
                WHEN listing->'cites_status' = 'LISTED'
                THEN listing->'cites_listing_original'
                ELSE NULL
              END
            )
            AS inherited_listing
            FROM taxon_concepts h
            WHERE listing->'cites_status_original' = 't'

            UNION ALL

            SELECT hi, hi.id,
            CASE
            WHEN
              hi.listing->'cites_status_original' = 't'
            THEN
              hstore('cites_listing',hi.listing->'cites_listing_original') ||
              slice(hi.listing, ARRAY['hash_ann_symbol', 'ann_symbol'])
            ELSE
              inherited_listing
            END
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
          )
          UPDATE taxon_concepts
          SET listing = listing || q.inherited_listing
          FROM q
          WHERE taxon_concepts.id = q.id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_descendant_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_descendant_listings() IS 'Procedure to rebuild the computed descendant listings in taxon_concepts.';


--
-- Name: rebuild_fully_covered_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_fully_covered_flags() RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
          cites_eu_id int;
          exception_id int;
        BEGIN
        SELECT id INTO cites_eu_id FROM taxonomies WHERE name = 'CITES_EU';
        SELECT id INTO exception_id FROM change_types WHERE name = 'EXCEPTION';

        -- set the fully_covered flag to true for all taxa (so we start clear)
        UPDATE taxon_concepts SET listing = listing ||
          hstore('cites_fully_covered', 't')
        WHERE taxonomy_id = cites_eu_id;

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
            WHERE taxonomy_id = cites_eu_id AND (
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
          WHERE is_current = 't' AND taxonomy_id = cites_eu_id
            AND NOT listing_distributions.is_party

          EXCEPT

          SELECT taxon_concept_id AS id FROM listing_distributions
          RIGHT JOIN listing_changes
            ON listing_changes.id = listing_distributions.listing_change_id
          INNER JOIN taxon_concepts
            ON taxon_concepts.id = listing_changes.taxon_concept_id
          WHERE is_current = 't' AND taxonomy_id = cites_eu_id
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

COMMENT ON FUNCTION rebuild_fully_covered_flags() IS 'Procedure to rebuild the fully_covered flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - all descendants are listed, "f" - some descendants were excluded or deleted from listing';


--
-- Name: rebuild_listing_changes_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_listing_changes_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
      BEGIN
        RAISE NOTICE 'Dropping listing changes materialized view';
        DROP table IF EXISTS listing_changes_mview;

        RAISE NOTICE 'Creating listing changes materialized view';
        CREATE TABLE listing_changes_mview AS
        SELECT *,
        false as dirty,
        null::timestamp with time zone as expiry
        FROM listing_changes_view;

        CREATE UNIQUE INDEX listing_changes_mview_on_id ON listing_changes_mview (id);
        CREATE INDEX listing_changes_mview_on_taxon_concept_id ON listing_changes_mview (taxon_concept_id);
      END;
      $$;


--
-- Name: FUNCTION rebuild_listing_changes_mview(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_listing_changes_mview() IS 'Procedure to rebuild listing changes materialized view in the database.';


--
-- Name: rebuild_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        PERFORM rebuild_annotation_symbols();

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
              hstore('cites_III', CASE WHEN SUM(cites_III) > 0 THEN 'III' ELSE NULL END)
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
                  AND change_types.name = 'DELETION' AND
                    (listing_distributions.id IS NULL OR NOT listing_distributions.is_party) THEN -1
                ELSE 0
              END AS cites_III
              FROM listing_changes 

              INNER JOIN change_types ON change_type_id = change_types.id
              AND change_types.name IN ('ADDITION','DELETION')
              AND effective_at <= NOW()
              INNER JOIN species_listings ON species_listing_id = species_listings.id
              INNER JOIN taxon_concepts ON taxon_concept_id = taxon_concepts.id
              INNER JOIN taxonomies ON taxon_concepts.taxonomy_id = taxonomies.id
              LEFT JOIN listing_distributions
                ON listing_distributions.listing_change_id = listing_changes.id
              WHERE taxonomies.name = 'CITES_EU'
              AND is_current = 't' 
            ) AS q
            GROUP BY taxon_concept_id
          ) AS qq
        ) AS qqq
        WHERE taxon_concepts.id = qqq.taxon_concept_id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_listings() IS 'Procedure to rebuild the computed listings in taxon_concepts.';


--
-- Name: rebuild_mviews(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_mviews() RETURNS void
    LANGUAGE plpgsql
    AS $$
      BEGIN
        PERFORM rebuild_taxon_concepts_mview();
        PERFORM rebuild_listing_changes_mview();
      END;
      $$;


--
-- Name: FUNCTION rebuild_mviews(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_mviews() IS 'Procedure to rebuild materialized views in the database.';


--
-- Name: rebuild_names_and_ranks(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_names_and_ranks() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    root_id integer;
  BEGIN
    FOR root_id IN SELECT id FROM taxon_concepts
    WHERE parent_id IS NULL AND name_status = 'A'
    LOOP
      PERFORM rebuild_names_and_ranks_from_root(root_id);
    END LOOP;

  END;
  $$;


--
-- Name: FUNCTION rebuild_names_and_ranks(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_names_and_ranks() IS 'Procedure to rebuild the computed full name, rank and ancestor names fields in taxon_concepts.';


--
-- Name: rebuild_names_and_ranks_for_node(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_names_and_ranks_for_node(node_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    WITH q AS (
      SELECT taxon_concepts.id, ranks.name AS rank_name, ancestors_data(node_id) AS ancestors
      FROM taxon_concepts
      INNER JOIN ranks ON taxon_concepts.rank_id = ranks.id
      WHERE taxon_concepts.id = node_id
    )
    UPDATE taxon_concepts
    SET full_name = full_name(rank_name, ancestors),
      data = CASE WHEN data IS NULL THEN ''::HSTORE ELSE data END ||
        ancestors || hstore('rank_name', rank_name)
    FROM q
    WHERE taxon_concepts.id = q.id AND taxon_concepts.name_status NOT IN ('S', 'H');
  END;
  $$;


--
-- Name: rebuild_names_and_ranks_from_root(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_names_and_ranks_from_root(root_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RAISE NOTICE 'rebuild names and ranks from %', root_id;
    WITH RECURSIVE q AS (
      SELECT h.id, ranks.name as rank_name,
      hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
      hstore(LOWER(ranks.name) || '_id', (h.id)::VARCHAR) AS ancestors
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = root_id

      UNION ALL

      SELECT hi.id, ranks.name,
      ancestors ||
      hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
      hstore(LOWER(ranks.name) || '_id', (hi.id)::VARCHAR)
      FROM q
      JOIN taxon_concepts hi
      ON hi.parent_id = q.id
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET
    full_name = full_name(rank_name, ancestors),
    data = data || ancestors || hstore('rank_name', rank_name)
    FROM q
    WHERE taxon_concepts.id = q.id;

  END;
  $$;


--
-- Name: FUNCTION rebuild_names_and_ranks_from_root(root_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_names_and_ranks_from_root(root_id integer) IS 'Procedure to rebuild the computed full name, rank and ancestor names fields in taxon_concepts.';


--
-- Name: rebuild_taxon_concepts_mview(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxon_concepts_mview() RETURNS void
    LANGUAGE plpgsql
    AS $$
      BEGIN
        RAISE NOTICE 'Dropping taxon concepts materialized view';
        DROP table IF EXISTS taxon_concepts_mview;

        RAISE NOTICE 'Creating taxon concepts materialized view';
        CREATE TABLE taxon_concepts_mview AS
        SELECT *,
        false as dirty,
        null::timestamp with time zone as expiry
        FROM taxon_concepts_view;

        CREATE UNIQUE INDEX taxon_concepts_mview_on_id ON taxon_concepts_mview (id);
        CREATE INDEX taxon_concepts_mview_on_history_filter ON taxon_concepts_mview (taxonomy_is_cites_eu, cites_listed, kingdom_position);
        CREATE INDEX taxon_concepts_mview_on_full_name ON taxon_concepts_mview (full_name);
        CREATE INDEX taxon_concepts_mview_on_parent_id ON taxon_concepts_mview (parent_id);
      END;
      $$;


--
-- Name: FUNCTION rebuild_taxon_concepts_mview(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_taxon_concepts_mview() IS 'Procedure to rebuild taxon concepts materialized view in the database.';


--
-- Name: rebuild_taxonomic_positions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomic_positions() RETURNS void
    LANGUAGE plpgsql
    AS $$
  DECLARE
    root_id integer;
  BEGIN

    FOR root_id IN SELECT id FROM taxon_concepts
      WHERE parent_id IS NULL
    LOOP
      PERFORM rebuild_taxonomic_positions_from_root(root_id);
    END LOOP;

  END;
  $$;


--
-- Name: FUNCTION rebuild_taxonomic_positions(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_taxonomic_positions() IS 'Procedure to rebuild the computed taxonomic position fields in taxon_concepts.';


--
-- Name: rebuild_taxonomic_positions_from_root(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomic_positions_from_root(root_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
  BEGIN

    WITH RECURSIVE q AS (
      SELECT h.id, h.taxonomic_position, ranks.fixed_order AS fixed_order
      FROM taxon_concepts h
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = root_id

      UNION ALL

      SELECT hi.id,
      CASE
        WHEN (ranks.fixed_order) THEN hi.taxonomic_position
        -- use generous zero padding to accommodate for orchidacea (30 thousand species in about 900 genera)
        ELSE (q.taxonomic_position || '.' || LPAD(
          (row_number() OVER (PARTITION BY parent_id ORDER BY full_name)::VARCHAR(64)),
          5,
          '0'
        ))::VARCHAR(255)
      END, ranks.fixed_order
      FROM q
      JOIN taxon_concepts hi ON hi.parent_id = q.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET taxonomic_position = q.taxonomic_position
    FROM q
    WHERE q.id = taxon_concepts.id;

  END;
  $$;


--
-- Name: FUNCTION rebuild_taxonomic_positions_from_root(root_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_taxonomic_positions_from_root(root_id integer) IS 'Procedure to rebuild the computed taxonomic position fields in taxon_concepts starting from root given by root_id.';


--
-- Name: sapi_rebuild(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sapi_rebuild() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
          RAISE NOTICE 'Rebuilding SAPI database';
          --RAISE NOTICE 'names and ranks';
          PERFORM rebuild_names_and_ranks();
          --RAISE NOTICE 'taxonomic positions';
          PERFORM rebuild_taxonomic_positions();
          PERFORM rebuild_cites_status();
          PERFORM rebuild_fully_covered_flags();
          PERFORM rebuild_cites_nc_flags();
          --RAISE NOTICE 'listings';
          PERFORM rebuild_listings();
          --RAISE NOTICE 'descendant listings';
          PERFORM rebuild_descendant_listings();
          --RAISE NOTICE 'ancestor listings';
          PERFORM rebuild_ancestor_listings();
          PERFORM rebuild_cites_accepted_flags();
          PERFORM rebuild_cites_show_flags();
        END;
      $$;


--
-- Name: FUNCTION sapi_rebuild(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION sapi_rebuild() IS 'Procedure to rebuild computed fields in the database.';


--
-- Name: taxon_concepts_invalidate_row(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION taxon_concepts_invalidate_row(row_id integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE taxon_concepts_mview tc
  SET dirty = TRUE
  WHERE tc.id = row_id;
  RETURN;
END
$$;


--
-- Name: taxon_concepts_refresh_row(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION taxon_concepts_refresh_row(row_id integer) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  DELETE
  FROM taxon_concepts_mview tc
  WHERE tc.id = row_id;

  INSERT INTO taxon_concepts_mview
  SELECT *, FALSE, NULL
  FROM taxon_concepts_view tc
  WHERE tc.id = row_id;
END
$$;


--
-- Name: trg_common_names_u(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_common_names_u() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  IF OLD.name <> NEW.name THEN
    PERFORM taxon_concepts_refresh_row(tc.id)
    FROM taxon_concepts tc
    INNER JOIN taxon_commons tc_c ON tc_c.taxon_concept_id = tc.id
    WHERE tc_c.common_name_id = NEW.id;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: trg_distributions_d(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_distributions_d() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = OLD.taxon_concept_id;
  RETURN NULL;
END
$$;


--
-- Name: trg_distributions_ui(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_distributions_ui() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = NEW.taxon_concept_id;
  RETURN NULL;
END
$$;


--
-- Name: trg_geo_entities_u(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_geo_entities_u() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  IF OLD.name <> NEW.name THEN
    PERFORM taxon_concepts_refresh_row(tc.id)
    FROM taxon_concepts tc
    INNER JOIN distributions tc_ge ON tc_ge.taxon_concept_id = tc.id
    WHERE tc_ge.geo_entity_id = NEW.id;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: trg_ranks_u(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_ranks_u() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  IF OLD.name <> NEW.name THEN
    PERFORM rebuild_names_and_ranks_for_node(tc.id)
    FROM taxon_concepts tc
    WHERE tc.rank_id = NEW.id;
    --PERFORM taxon_concepts_refresh_row(tc.id)
    --FROM taxon_concepts tc
    --WHERE tc.rank_id = NEW.id;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_commons_d(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_commons_d() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = OLD.taxon_concept_id;
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_commons_ui(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_commons_ui() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = NEW.taxon_concept_id;
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_concept_references_d(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_concept_references_d() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = OLD.taxon_concept_id;
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_concept_references_ui(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_concept_references_ui() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = NEW.taxon_concept_id;
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_concepts_d(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_concepts_d() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(OLD.id);
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_concepts_i(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_concepts_i() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  IF NEW.parent_id IS NOT NULL THEN
    PERFORM rebuild_taxonomic_positions_from_root(NEW.parent_id);
  ELSE
    PERFORM rebuild_taxonomic_positions_from_root(NEW.id);
  END IF;
  PERFORM rebuild_names_and_ranks_for_node(NEW.id);
  PERFORM taxon_concepts_refresh_row(NEW.id);
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_concepts_u(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_concepts_u() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  IF OLD.taxonomic_position <> NEW.taxonomic_position OR OLD.parent_id <> NEW.parent_id THEN
    IF NEW.parent_id IS NOT NULL THEN
      PERFORM rebuild_taxonomic_positions_from_root(NEW.parent_id);
    ELSE
      PERFORM rebuild_taxonomic_positions_from_root(NEW.id);
    END IF;
  END IF;
  IF OLD.taxon_name_id <> NEW.taxon_name_id OR OLD.rank_id <> NEW.rank_id OR
    (OLD.data->'full_name') <> (NEW.data->'full_name') OR
    (OLD.data->'rank_name') <> (NEW.data->'rank_name') THEN
    PERFORM taxon_concepts_refresh_row(NEW.id);
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_names_u(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_names_u() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  IF OLD.name <> NEW.name THEN
    PERFORM taxon_concepts_refresh_row(tc.id)
    FROM taxon_concepts tc
    WHERE tc.taxon_name_id = NEW.id;
  END IF;
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_relationships_d(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_relationships_d() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  INNER JOIN taxon_relationships tc_r ON tc_r.taxon_concept_id = tc.id
  INNER JOIN taxon_relationship_types tc_rt ON tc_rt.id = tc_r.taxon_relationship_type_id
    AND tc_rt.name = 'HAS_SYNONYM'
  WHERE tc.id = OLD.taxon_concept_id;
  RETURN NULL;
END
$$;


--
-- Name: trg_taxon_relationships_ui(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_taxon_relationships_ui() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  INNER JOIN taxon_relationships tc_r ON tc_r.taxon_concept_id = tc.id
  INNER JOIN taxon_relationship_types tc_rt ON tc_rt.id = tc_r.taxon_relationship_type_id
    AND tc_rt.name = 'HAS_SYNONYM'
  WHERE tc.id = NEW.taxon_concept_id;
  RETURN NULL;
END
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: annotation_translations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE annotation_translations (
    id integer NOT NULL,
    annotation_id integer NOT NULL,
    language_id integer NOT NULL,
    short_note character varying(255),
    full_note text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: annotation_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE annotation_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annotation_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE annotation_translations_id_seq OWNED BY annotation_translations.id;


--
-- Name: annotations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE annotations (
    id integer NOT NULL,
    symbol character varying(255),
    parent_symbol character varying(255),
    listing_change_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    short_note_en text,
    full_note_en text,
    short_note_fr text,
    full_note_fr text,
    short_note_es text,
    full_note_es text,
    display_in_index boolean DEFAULT false NOT NULL,
    display_in_footnote boolean DEFAULT false NOT NULL
);


--
-- Name: annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE annotations_id_seq OWNED BY annotations.id;


--
-- Name: change_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE change_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    designation_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: change_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE change_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE change_types_id_seq OWNED BY change_types.id;


--
-- Name: cites_listings_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cites_listings_import (
    rank character varying,
    legacy_id integer,
    appendix character varying,
    listing_date date,
    country_iso2 character varying,
    is_current boolean,
    populations_iso2 character varying,
    excluded_populations_iso2 character varying,
    is_inclusion boolean,
    included_in_rec_id integer,
    rank_for_inclusions character varying,
    excluded_taxa character varying,
    short_note_en character varying,
    short_note_es character varying,
    short_note_fr character varying,
    full_note_en character varying,
    index_annotation integer,
    history_annotation integer,
    hash_note character varying,
    notes character varying
);


--
-- Name: cites_listings_import_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW cites_listings_import_view AS
    SELECT row_number() OVER () AS row_id, cites_listings_import.rank, cites_listings_import.legacy_id, cites_listings_import.appendix, cites_listings_import.listing_date, cites_listings_import.country_iso2, cites_listings_import.is_current, cites_listings_import.populations_iso2, cites_listings_import.excluded_populations_iso2, cites_listings_import.is_inclusion, cites_listings_import.included_in_rec_id, cites_listings_import.rank_for_inclusions, cites_listings_import.excluded_taxa, cites_listings_import.short_note_en, cites_listings_import.short_note_es, cites_listings_import.short_note_fr, cites_listings_import.full_note_en, cites_listings_import.index_annotation, cites_listings_import.history_annotation, cites_listings_import.hash_note, cites_listings_import.notes FROM cites_listings_import ORDER BY cites_listings_import.legacy_id, cites_listings_import.listing_date, cites_listings_import.appendix, cites_listings_import.country_iso2;


--
-- Name: cites_regions_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cites_regions_import (
    name character varying
);


--
-- Name: common_name_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE common_name_import (
    name character varying,
    language character varying,
    legacy_id integer,
    rank character varying,
    designation character varying,
    reference_id character varying
);


--
-- Name: common_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE common_names (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    language_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: common_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE common_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: common_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE common_names_id_seq OWNED BY common_names.id;


--
-- Name: countries_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries_import (
    iso2 character varying,
    name character varying,
    geo_entity character varying,
    bru_under character varying,
    current_name character varying,
    long_name character varying,
    cites_region character varying
);


--
-- Name: designations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE designations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    taxonomy_id integer DEFAULT 1 NOT NULL
);


--
-- Name: designations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE designations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: designations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE designations_id_seq OWNED BY designations.id;


--
-- Name: distribution_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE distribution_import (
    legacy_id integer,
    rank character varying,
    geo_entity_type character varying,
    country_iso2 character varying,
    reference_id integer,
    designation character varying
);


--
-- Name: distribution_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE distribution_references (
    id integer NOT NULL,
    distribution_id integer NOT NULL,
    reference_id integer NOT NULL
);


--
-- Name: distribution_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE distribution_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: distribution_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE distribution_references_id_seq OWNED BY distribution_references.id;


--
-- Name: distributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE distributions (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    geo_entity_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: distributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: distributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE distributions_id_seq OWNED BY distributions.id;


--
-- Name: downloads; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE downloads (
    id integer NOT NULL,
    doc_type character varying(255),
    format character varying(255),
    status character varying(255) DEFAULT 'working'::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    path character varying(255),
    filename character varying(255),
    display_name character varying(255)
);


--
-- Name: downloads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE downloads_id_seq OWNED BY downloads.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: geo_entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_entities (
    id integer NOT NULL,
    geo_entity_type_id integer NOT NULL,
    name_en character varying(255) NOT NULL,
    long_name character varying(255),
    iso_code2 character varying(255),
    iso_code3 character varying(255),
    legacy_id integer,
    legacy_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_current boolean DEFAULT true,
    name_fr character varying(255),
    name_es character varying(255)
);


--
-- Name: geo_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geo_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geo_entities_id_seq OWNED BY geo_entities.id;


--
-- Name: geo_entity_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_entity_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: geo_entity_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geo_entity_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_entity_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geo_entity_types_id_seq OWNED BY geo_entity_types.id;


--
-- Name: geo_relationship_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_relationship_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: geo_relationship_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geo_relationship_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_relationship_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geo_relationship_types_id_seq OWNED BY geo_relationship_types.id;


--
-- Name: geo_relationships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_relationships (
    id integer NOT NULL,
    geo_entity_id integer NOT NULL,
    other_geo_entity_id integer NOT NULL,
    geo_relationship_type_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: geo_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE geo_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geo_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE geo_relationships_id_seq OWNED BY geo_relationships.id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE languages (
    id integer NOT NULL,
    name_en character varying(255),
    iso_code1 character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name_fr character varying(255),
    name_es character varying(255)
);


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE languages_id_seq OWNED BY languages.id;


--
-- Name: listing_changes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE listing_changes (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    species_listing_id integer,
    change_type_id integer NOT NULL,
    effective_at timestamp without time zone DEFAULT '2012-09-21 07:32:20'::timestamp without time zone NOT NULL,
    is_current boolean DEFAULT false NOT NULL,
    annotation_id integer,
    parent_id integer,
    inclusion_taxon_concept_id integer,
    lft integer,
    rgt integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    import_row_id integer,
    hash_annotation_id integer
);


--
-- Name: listing_changes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE listing_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: listing_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE listing_changes_id_seq OWNED BY listing_changes.id;


--
-- Name: listing_changes_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE listing_changes_mview (
    id integer,
    taxon_concept_id integer,
    effective_at timestamp without time zone,
    species_listing_id integer,
    species_listing_name character varying(255),
    change_type_id integer,
    change_type_name character varying(255),
    party_id integer,
    party_name character varying(255),
    ann_symbol character varying(255),
    full_note_en text,
    full_note_es text,
    full_note_fr text,
    short_note_en text,
    short_note_es text,
    short_note_fr text,
    display_in_index boolean,
    display_in_footnote boolean,
    hash_ann_symbol character varying(255),
    hash_ann_parent_symbol character varying(255),
    hash_full_note_en text,
    hash_full_note_es text,
    hash_full_note_fr text,
    is_current boolean,
    countries_ids_ary integer[],
    dirty boolean,
    expiry timestamp with time zone
);


--
-- Name: listing_distributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE listing_distributions (
    id integer NOT NULL,
    listing_change_id integer NOT NULL,
    geo_entity_id integer NOT NULL,
    is_party boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: species_listings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE species_listings (
    id integer NOT NULL,
    designation_id integer NOT NULL,
    name character varying(255) NOT NULL,
    abbreviation character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: listing_changes_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW listing_changes_view AS
    SELECT listing_changes.id, listing_changes.taxon_concept_id, listing_changes.effective_at, listing_changes.species_listing_id, species_listings.abbreviation AS species_listing_name, listing_changes.change_type_id, change_types.name AS change_type_name, listing_distributions.geo_entity_id AS party_id, geo_entities.iso_code2 AS party_name, annotations.symbol AS ann_symbol, annotations.full_note_en, annotations.full_note_es, annotations.full_note_fr, annotations.short_note_en, annotations.short_note_es, annotations.short_note_fr, annotations.display_in_index, annotations.display_in_footnote, hash_annotations.symbol AS hash_ann_symbol, hash_annotations.parent_symbol AS hash_ann_parent_symbol, hash_annotations.full_note_en AS hash_full_note_en, hash_annotations.full_note_es AS hash_full_note_es, hash_annotations.full_note_fr AS hash_full_note_fr, listing_changes.is_current, populations.countries_ids_ary FROM (((((((listing_changes JOIN change_types ON ((listing_changes.change_type_id = change_types.id))) LEFT JOIN species_listings ON ((listing_changes.species_listing_id = species_listings.id))) LEFT JOIN listing_distributions ON (((listing_changes.id = listing_distributions.listing_change_id) AND (listing_distributions.is_party = true)))) LEFT JOIN geo_entities ON ((geo_entities.id = listing_distributions.geo_entity_id))) LEFT JOIN annotations ON ((annotations.id = listing_changes.annotation_id))) LEFT JOIN annotations hash_annotations ON ((annotations.id = listing_changes.hash_annotation_id))) LEFT JOIN (SELECT listing_distributions.listing_change_id, array_agg(geo_entities.id) AS countries_ids_ary FROM (listing_distributions JOIN geo_entities ON ((geo_entities.id = listing_distributions.geo_entity_id))) WHERE (NOT listing_distributions.is_party) GROUP BY listing_distributions.listing_change_id) populations ON ((populations.listing_change_id = listing_changes.id))) ORDER BY listing_changes.taxon_concept_id, listing_changes.effective_at, CASE WHEN ((change_types.name)::text = 'ADDITION'::text) THEN 0 WHEN ((change_types.name)::text = 'RESERVATION'::text) THEN 1 WHEN ((change_types.name)::text = 'RESERVATION_WITHDRAWAL'::text) THEN 2 WHEN ((change_types.name)::text = 'DELETION'::text) THEN 3 ELSE NULL::integer END;


--
-- Name: listing_distributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE listing_distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: listing_distributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE listing_distributions_id_seq OWNED BY listing_distributions.id;


--
-- Name: ranks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ranks (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    taxonomic_position character varying(255) DEFAULT '0'::character varying NOT NULL,
    fixed_order boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ranks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ranks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ranks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ranks_id_seq OWNED BY ranks.id;


--
-- Name: references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "references" (
    id integer NOT NULL,
    title text NOT NULL,
    year character varying(255),
    author character varying(255),
    legacy_id integer,
    legacy_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE references_id_seq OWNED BY "references".id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: species_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE species_import (
    name character varying,
    rank character varying,
    legacy_id integer,
    parent_rank character varying,
    parent_legacy_id integer,
    status character varying,
    author character varying,
    notes character varying,
    taxonomy character varying
);


--
-- Name: species_listings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE species_listings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: species_listings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE species_listings_id_seq OWNED BY species_listings.id;


--
-- Name: standard_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE standard_references (
    id integer NOT NULL,
    author character varying(255),
    title text,
    year integer,
    reference_id integer,
    reference_legacy_id integer,
    taxon_concept_name character varying(255),
    taxon_concept_rank character varying(255),
    taxon_concept_id integer,
    species_legacy_id integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: standard_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE standard_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: standard_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE standard_references_id_seq OWNED BY standard_references.id;


--
-- Name: standard_references_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE standard_references_import (
    name character varying,
    rank character varying,
    taxon_legacy_id integer,
    ref_legacy_id integer,
    exclusions character varying,
    cascade boolean,
    designation character varying
);


--
-- Name: synonym_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE synonym_import (
    name character varying,
    rank character varying,
    legacy_id integer,
    parent_rank character varying,
    parent_legacy_id integer,
    status character varying,
    author character varying,
    notes character varying,
    reference_ids character varying,
    taxonomy character varying,
    accepted_rank character varying,
    accepted_legacy_id integer
);


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying(255),
    tagger_id integer,
    tagger_type character varying(255),
    context character varying(128),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: taxon_commons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_commons (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    common_name_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_commons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_commons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_commons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_commons_id_seq OWNED BY taxon_commons.id;


--
-- Name: taxon_concept_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concept_references (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    reference_id integer NOT NULL,
    data hstore
);


--
-- Name: taxon_concept_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_concept_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_concept_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_concept_references_id_seq OWNED BY taxon_concept_references.id;


--
-- Name: taxon_concepts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concepts (
    id integer NOT NULL,
    parent_id integer,
    rank_id integer NOT NULL,
    taxon_name_id integer NOT NULL,
    author_year character varying(255),
    legacy_id integer,
    legacy_type character varying(255),
    data hstore,
    listing hstore,
    notes text,
    taxonomic_position character varying(255) DEFAULT '0'::character varying NOT NULL,
    full_name character varying(255),
    name_status character varying(255) DEFAULT 'A'::character varying NOT NULL,
    lft integer,
    rgt integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    taxonomy_id integer DEFAULT 1 NOT NULL
);


--
-- Name: taxon_concepts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_concepts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_concepts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_concepts_id_seq OWNED BY taxon_concepts.id;


--
-- Name: taxon_concepts_mview; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concepts_mview (
    id integer,
    parent_id integer,
    taxonomy_is_cites_eu boolean,
    full_name character varying(255),
    name_status character varying(255),
    rank_name text,
    cites_accepted boolean,
    kingdom_position integer,
    taxonomic_position character varying(255),
    kingdom_name text,
    phylum_name text,
    class_name text,
    order_name text,
    family_name text,
    genus_name text,
    species_name text,
    subspecies_name text,
    kingdom_id integer,
    phylum_id integer,
    class_id integer,
    order_id integer,
    family_id integer,
    genus_id integer,
    species_id integer,
    subspecies_id integer,
    cites_fully_covered boolean,
    cites_listed boolean,
    cites_deleted boolean,
    cites_excluded boolean,
    cites_show boolean,
    cites_i boolean,
    cites_ii boolean,
    cites_iii boolean,
    current_listing text,
    listing_updated_at timestamp without time zone,
    ann_symbol text,
    hash_ann_symbol text,
    hash_ann_parent_symbol text,
    author_year character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    taxon_concept_id_com integer,
    english_names_ary character varying[],
    french_names_ary character varying[],
    spanish_names_ary character varying[],
    taxon_concept_id_syn integer,
    synonyms_ary character varying[],
    synonyms_author_years_ary character varying[],
    countries_ids_ary integer[],
    standard_references_ids_ary integer[],
    dirty boolean,
    expiry timestamp with time zone
);


--
-- Name: taxon_concepts_view; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concepts_view (
    id integer,
    parent_id integer,
    taxonomy_is_cites_eu boolean,
    full_name character varying(255),
    name_status character varying(255),
    rank_name text,
    cites_accepted boolean,
    kingdom_position integer,
    taxonomic_position character varying(255),
    kingdom_name text,
    phylum_name text,
    class_name text,
    order_name text,
    family_name text,
    genus_name text,
    species_name text,
    subspecies_name text,
    kingdom_id integer,
    phylum_id integer,
    class_id integer,
    order_id integer,
    family_id integer,
    genus_id integer,
    species_id integer,
    subspecies_id integer,
    cites_fully_covered boolean,
    cites_listed boolean,
    cites_deleted boolean,
    cites_excluded boolean,
    cites_show boolean,
    cites_i boolean,
    cites_ii boolean,
    cites_iii boolean,
    current_listing text,
    listing_updated_at timestamp without time zone,
    ann_symbol text,
    hash_ann_symbol text,
    hash_ann_parent_symbol text,
    author_year character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    taxon_concept_id_com integer,
    english_names_ary character varying[],
    french_names_ary character varying[],
    spanish_names_ary character varying[],
    taxon_concept_id_syn integer,
    synonyms_ary character varying[],
    synonyms_author_years_ary character varying[],
    countries_ids_ary integer[],
    standard_references_ids_ary integer[]
);


--
-- Name: taxon_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_names (
    id integer NOT NULL,
    scientific_name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_names_id_seq OWNED BY taxon_names.id;


--
-- Name: taxon_relationship_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_relationship_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    is_intertaxonomic boolean DEFAULT false NOT NULL,
    is_bidirectional boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_relationship_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_relationship_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_relationship_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_relationship_types_id_seq OWNED BY taxon_relationship_types.id;


--
-- Name: taxon_relationships; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_relationships (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    other_taxon_concept_id integer NOT NULL,
    taxon_relationship_type_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_relationships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_relationships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_relationships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_relationships_id_seq OWNED BY taxon_relationships.id;


--
-- Name: taxonomies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxonomies (
    id integer NOT NULL,
    name character varying(255) DEFAULT 'DEAFAULT TAXONOMY'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxonomies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxonomies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxonomies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxonomies_id_seq OWNED BY taxonomies.id;


--
-- Name: trade_codes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trade_codes (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    name_es character varying(255),
    name_fr character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trade_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trade_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trade_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trade_codes_id_seq OWNED BY trade_codes.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotation_translations ALTER COLUMN id SET DEFAULT nextval('annotation_translations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotations ALTER COLUMN id SET DEFAULT nextval('annotations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY change_types ALTER COLUMN id SET DEFAULT nextval('change_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY common_names ALTER COLUMN id SET DEFAULT nextval('common_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY designations ALTER COLUMN id SET DEFAULT nextval('designations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY distribution_references ALTER COLUMN id SET DEFAULT nextval('distribution_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions ALTER COLUMN id SET DEFAULT nextval('distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY downloads ALTER COLUMN id SET DEFAULT nextval('downloads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_entities ALTER COLUMN id SET DEFAULT nextval('geo_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_entity_types ALTER COLUMN id SET DEFAULT nextval('geo_entity_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationship_types ALTER COLUMN id SET DEFAULT nextval('geo_relationship_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationships ALTER COLUMN id SET DEFAULT nextval('geo_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY languages ALTER COLUMN id SET DEFAULT nextval('languages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes ALTER COLUMN id SET DEFAULT nextval('listing_changes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_distributions ALTER COLUMN id SET DEFAULT nextval('listing_distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ranks ALTER COLUMN id SET DEFAULT nextval('ranks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "references" ALTER COLUMN id SET DEFAULT nextval('references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY species_listings ALTER COLUMN id SET DEFAULT nextval('species_listings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY standard_references ALTER COLUMN id SET DEFAULT nextval('standard_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_commons ALTER COLUMN id SET DEFAULT nextval('taxon_commons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_references ALTER COLUMN id SET DEFAULT nextval('taxon_concept_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts ALTER COLUMN id SET DEFAULT nextval('taxon_concepts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_names ALTER COLUMN id SET DEFAULT nextval('taxon_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationship_types ALTER COLUMN id SET DEFAULT nextval('taxon_relationship_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationships ALTER COLUMN id SET DEFAULT nextval('taxon_relationships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxonomies ALTER COLUMN id SET DEFAULT nextval('taxonomies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trade_codes ALTER COLUMN id SET DEFAULT nextval('trade_codes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: annotation_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY annotation_translations
    ADD CONSTRAINT annotation_translations_pkey PRIMARY KEY (id);


--
-- Name: annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_pkey PRIMARY KEY (id);


--
-- Name: change_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY change_types
    ADD CONSTRAINT change_types_pkey PRIMARY KEY (id);


--
-- Name: common_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY common_names
    ADD CONSTRAINT common_names_pkey PRIMARY KEY (id);


--
-- Name: designations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY designations
    ADD CONSTRAINT designations_pkey PRIMARY KEY (id);


--
-- Name: downloads_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY downloads
    ADD CONSTRAINT downloads_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: geo_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geo_entities
    ADD CONSTRAINT geo_entities_pkey PRIMARY KEY (id);


--
-- Name: geo_entity_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geo_entity_types
    ADD CONSTRAINT geo_entity_types_pkey PRIMARY KEY (id);


--
-- Name: geo_relationship_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geo_relationship_types
    ADD CONSTRAINT geo_relationship_types_pkey PRIMARY KEY (id);


--
-- Name: geo_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY geo_relationships
    ADD CONSTRAINT geo_relationships_pkey PRIMARY KEY (id);


--
-- Name: languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: listing_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_pkey PRIMARY KEY (id);


--
-- Name: listing_distributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listing_distributions
    ADD CONSTRAINT listing_distributions_pkey PRIMARY KEY (id);


--
-- Name: ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (id);


--
-- Name: references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "references"
    ADD CONSTRAINT references_pkey PRIMARY KEY (id);


--
-- Name: species_listings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY species_listings
    ADD CONSTRAINT species_listings_pkey PRIMARY KEY (id);


--
-- Name: standard_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY standard_references
    ADD CONSTRAINT standard_references_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: taxon_commons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_commons
    ADD CONSTRAINT taxon_commons_pkey PRIMARY KEY (id);


--
-- Name: taxon_concept_geo_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT taxon_concept_geo_entities_pkey PRIMARY KEY (id);


--
-- Name: taxon_concept_geo_entity_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY distribution_references
    ADD CONSTRAINT taxon_concept_geo_entity_references_pkey PRIMARY KEY (id);


--
-- Name: taxon_concept_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_concept_references
    ADD CONSTRAINT taxon_concept_references_pkey PRIMARY KEY (id);


--
-- Name: taxon_concepts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_pkey PRIMARY KEY (id);


--
-- Name: taxon_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_names
    ADD CONSTRAINT taxon_names_pkey PRIMARY KEY (id);


--
-- Name: taxon_relationship_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_relationship_types
    ADD CONSTRAINT taxon_relationship_types_pkey PRIMARY KEY (id);


--
-- Name: taxon_relationships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_relationships
    ADD CONSTRAINT taxon_relationships_pkey PRIMARY KEY (id);


--
-- Name: taxonomies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxonomies
    ADD CONSTRAINT taxonomies_pkey PRIMARY KEY (id);


--
-- Name: trade_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trade_codes
    ADD CONSTRAINT trade_codes_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_annotations_on_listing_change_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_annotations_on_listing_change_id ON annotations USING btree (listing_change_id);


--
-- Name: index_listing_changes_on_annotation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_annotation_id ON listing_changes USING btree (annotation_id);


--
-- Name: index_listing_changes_on_hash_annotation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_hash_annotation_id ON listing_changes USING btree (hash_annotation_id);


--
-- Name: index_listing_changes_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_parent_id ON listing_changes USING btree (parent_id);


--
-- Name: index_listing_distributions_on_geo_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_distributions_on_geo_entity_id ON listing_distributions USING btree (geo_entity_id);


--
-- Name: index_listing_distributions_on_listing_change_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_distributions_on_listing_change_id ON listing_distributions USING btree (listing_change_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_taxon_concepts_on_lft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_lft ON taxon_concepts USING btree (lft);


--
-- Name: index_taxon_concepts_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_parent_id ON taxon_concepts USING btree (parent_id);


--
-- Name: listing_changes_mview_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX listing_changes_mview_on_id ON listing_changes_mview USING btree (id);


--
-- Name: listing_changes_mview_on_taxon_concept_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX listing_changes_mview_on_taxon_concept_id ON listing_changes_mview USING btree (taxon_concept_id);


--
-- Name: taxon_concepts_mview_on_full_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_on_full_name ON taxon_concepts_mview USING btree (full_name);


--
-- Name: taxon_concepts_mview_on_history_filter; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_on_history_filter ON taxon_concepts_mview USING btree (taxonomy_is_cites_eu, cites_listed, kingdom_position);


--
-- Name: taxon_concepts_mview_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX taxon_concepts_mview_on_id ON taxon_concepts_mview USING btree (id);


--
-- Name: taxon_concepts_mview_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX taxon_concepts_mview_on_parent_id ON taxon_concepts_mview USING btree (parent_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS ON SELECT TO taxon_concepts_view DO INSTEAD SELECT taxon_concepts.id, taxon_concepts.parent_id, CASE WHEN ((taxonomies.name)::text = 'CITES_EU'::text) THEN true ELSE false END AS taxonomy_is_cites_eu, taxon_concepts.full_name, taxon_concepts.name_status, (taxon_concepts.data -> 'rank_name'::text) AS rank_name, ((taxon_concepts.data -> 'cites_accepted'::text))::boolean AS cites_accepted, CASE WHEN ((taxon_concepts.data -> 'kingdom_name'::text) = 'Animalia'::text) THEN 0 ELSE 1 END AS kingdom_position, taxon_concepts.taxonomic_position, (taxon_concepts.data -> 'kingdom_name'::text) AS kingdom_name, (taxon_concepts.data -> 'phylum_name'::text) AS phylum_name, (taxon_concepts.data -> 'class_name'::text) AS class_name, (taxon_concepts.data -> 'order_name'::text) AS order_name, (taxon_concepts.data -> 'family_name'::text) AS family_name, (taxon_concepts.data -> 'genus_name'::text) AS genus_name, (taxon_concepts.data -> 'species_name'::text) AS species_name, (taxon_concepts.data -> 'subspecies_name'::text) AS subspecies_name, ((taxon_concepts.data -> 'kingdom_id'::text))::integer AS kingdom_id, ((taxon_concepts.data -> 'phylum_id'::text))::integer AS phylum_id, ((taxon_concepts.data -> 'class_id'::text))::integer AS class_id, ((taxon_concepts.data -> 'order_id'::text))::integer AS order_id, ((taxon_concepts.data -> 'family_id'::text))::integer AS family_id, ((taxon_concepts.data -> 'genus_id'::text))::integer AS genus_id, ((taxon_concepts.data -> 'species_id'::text))::integer AS species_id, ((taxon_concepts.data -> 'subspecies_id'::text))::integer AS subspecies_id, ((taxon_concepts.listing -> 'cites_fully_covered'::text))::boolean AS cites_fully_covered, CASE WHEN (((taxon_concepts.listing -> 'cites_status'::text) = 'LISTED'::text) AND ((taxon_concepts.listing -> 'cites_status_original'::text) = 't'::text)) THEN true WHEN ((taxon_concepts.listing -> 'cites_status'::text) = 'LISTED'::text) THEN false ELSE NULL::boolean END AS cites_listed, CASE WHEN ((taxon_concepts.listing -> 'cites_status'::text) = 'DELETED'::text) THEN true ELSE false END AS cites_deleted, CASE WHEN ((taxon_concepts.listing -> 'cites_status'::text) = 'EXCLUDED'::text) THEN true ELSE false END AS cites_excluded, ((taxon_concepts.listing -> 'cites_show'::text))::boolean AS cites_show, CASE WHEN ((taxon_concepts.listing -> 'cites_I'::text) = 'I'::text) THEN true ELSE false END AS cites_i, CASE WHEN ((taxon_concepts.listing -> 'cites_II'::text) = 'II'::text) THEN true ELSE false END AS cites_ii, CASE WHEN ((taxon_concepts.listing -> 'cites_III'::text) = 'III'::text) THEN true ELSE false END AS cites_iii, (taxon_concepts.listing -> 'cites_listing'::text) AS current_listing, ((taxon_concepts.listing -> 'listing_updated_at'::text))::timestamp without time zone AS listing_updated_at, (taxon_concepts.listing -> 'ann_symbol'::text) AS ann_symbol, (taxon_concepts.listing -> 'hash_ann_symbol'::text) AS hash_ann_symbol, (taxon_concepts.listing -> 'hash_ann_parent_symbol'::text) AS hash_ann_parent_symbol, taxon_concepts.author_year, taxon_concepts.created_at, taxon_concepts.updated_at, common_names.taxon_concept_id_com, common_names.english_names_ary, common_names.french_names_ary, common_names.spanish_names_ary, synonyms.taxon_concept_id_syn, synonyms.synonyms_ary, synonyms.synonyms_author_years_ary, countries_ids.countries_ids_ary, standard_references_ids.standard_references_ids_ary FROM (((((taxon_concepts LEFT JOIN taxonomies ON ((taxonomies.id = taxon_concepts.taxonomy_id))) LEFT JOIN (SELECT ct.taxon_concept_id_com, ct.english_names_ary, ct.french_names_ary, ct.spanish_names_ary FROM crosstab('SELECT taxon_concepts.id AS taxon_concept_id_com,
    SUBSTRING(languages.name_en FROM 1 FOR 1) AS lng,
    ARRAY_AGG(common_names.name ORDER BY common_names.id) AS common_names_ary
    FROM "taxon_concepts"
    INNER JOIN "taxon_commons"
    ON "taxon_commons"."taxon_concept_id" = "taxon_concepts"."id"
    INNER JOIN "common_names"
    ON "common_names"."id" = "taxon_commons"."common_name_id"
    INNER JOIN "languages"
    ON "languages"."id" = "common_names"."language_id"
    GROUP BY taxon_concepts.id, SUBSTRING(languages.name_en FROM 1 FOR 1)
    ORDER BY 1,2'::text) ct(taxon_concept_id_com integer, english_names_ary character varying[], french_names_ary character varying[], spanish_names_ary character varying[])) common_names ON ((taxon_concepts.id = common_names.taxon_concept_id_com))) LEFT JOIN (SELECT taxon_concepts.id AS taxon_concept_id_syn, array_agg(synonym_tc.full_name) AS synonyms_ary, array_agg(synonym_tc.author_year) AS synonyms_author_years_ary FROM (((taxon_concepts LEFT JOIN taxon_relationships ON ((taxon_relationships.taxon_concept_id = taxon_concepts.id))) LEFT JOIN taxon_relationship_types ON ((taxon_relationship_types.id = taxon_relationships.taxon_relationship_type_id))) LEFT JOIN taxon_concepts synonym_tc ON ((synonym_tc.id = taxon_relationships.other_taxon_concept_id))) GROUP BY taxon_concepts.id) synonyms ON ((taxon_concepts.id = synonyms.taxon_concept_id_syn))) LEFT JOIN (SELECT taxon_concepts.id AS taxon_concept_id_cnt, array_agg(geo_entities.id ORDER BY geo_entities.name_en) AS countries_ids_ary FROM (((taxon_concepts LEFT JOIN distributions ON ((distributions.taxon_concept_id = taxon_concepts.id))) LEFT JOIN geo_entities ON ((distributions.geo_entity_id = geo_entities.id))) LEFT JOIN geo_entity_types ON (((geo_entity_types.id = geo_entities.geo_entity_type_id) AND ((geo_entity_types.name)::text = 'COUNTRY'::text)))) GROUP BY taxon_concepts.id) countries_ids ON ((taxon_concepts.id = countries_ids.taxon_concept_id_cnt))) LEFT JOIN (WITH taxa_with_std_refs AS (WITH RECURSIVE q AS (SELECT h.*::taxon_concepts AS h, h.id, array_agg(taxon_concept_references.reference_id) AS standard_references_ids_ary FROM (taxon_concepts h LEFT JOIN taxon_concept_references ON (((h.id = taxon_concept_references.taxon_concept_id) AND ((taxon_concept_references.data -> 'usr_is_std_ref'::text) = 't'::text)))) WHERE (h.parent_id IS NULL) GROUP BY h.id UNION ALL SELECT hi.*::taxon_concepts AS hi, hi.id, CASE WHEN (((hi.data -> 'usr_no_std_ref'::text))::boolean = true) THEN ARRAY[]::integer[] ELSE (q.standard_references_ids_ary || taxon_concept_references.reference_id) END AS "case" FROM ((q JOIN taxon_concepts hi ON ((hi.parent_id = (q.h).id))) LEFT JOIN taxon_concept_references ON (((hi.id = taxon_concept_references.taxon_concept_id) AND ((taxon_concept_references.data -> 'usr_is_std_ref'::text) = 't'::text))))) SELECT DISTINCT q.id, unnest(q.standard_references_ids_ary) AS std_ref_id FROM q) SELECT taxa_with_std_refs.id AS taxon_concept_id_sr, array_agg(taxa_with_std_refs.std_ref_id) AS standard_references_ids_ary FROM taxa_with_std_refs WHERE (taxa_with_std_refs.std_ref_id IS NOT NULL) GROUP BY taxa_with_std_refs.id) standard_references_ids ON ((taxon_concepts.id = standard_references_ids.taxon_concept_id_sr)));
ALTER VIEW taxon_concepts_view SET ();


--
-- Name: trg_common_names_u; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_common_names_u AFTER UPDATE ON common_names FOR EACH ROW EXECUTE PROCEDURE trg_common_names_u();


--
-- Name: trg_distributions_d; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_distributions_d AFTER DELETE ON distributions FOR EACH ROW EXECUTE PROCEDURE trg_distributions_d();


--
-- Name: trg_distributions_ui; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_distributions_ui AFTER INSERT OR UPDATE ON distributions FOR EACH ROW EXECUTE PROCEDURE trg_distributions_ui();


--
-- Name: trg_geo_entities_u; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_geo_entities_u AFTER UPDATE ON geo_entities FOR EACH ROW EXECUTE PROCEDURE trg_geo_entities_u();


--
-- Name: trg_ranks_u; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_ranks_u AFTER UPDATE ON ranks FOR EACH ROW EXECUTE PROCEDURE trg_ranks_u();


--
-- Name: trg_taxon_commons_d; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_commons_d AFTER DELETE ON taxon_commons FOR EACH ROW EXECUTE PROCEDURE trg_taxon_commons_d();


--
-- Name: trg_taxon_commons_ui; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_commons_ui AFTER INSERT OR UPDATE ON taxon_commons FOR EACH ROW EXECUTE PROCEDURE trg_taxon_commons_ui();


--
-- Name: trg_taxon_concept_references_d; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_concept_references_d AFTER DELETE ON taxon_concept_references FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concept_references_d();


--
-- Name: trg_taxon_concept_references_ui; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_concept_references_ui AFTER INSERT OR UPDATE ON taxon_concept_references FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concept_references_ui();


--
-- Name: trg_taxon_concepts_d; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_concepts_d AFTER DELETE ON taxon_concepts FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concepts_d();


--
-- Name: trg_taxon_concepts_i; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_concepts_i AFTER INSERT ON taxon_concepts FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concepts_i();


--
-- Name: trg_taxon_concepts_u; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_concepts_u AFTER UPDATE ON taxon_concepts FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concepts_u();


--
-- Name: trg_taxon_names_u; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_names_u AFTER UPDATE ON taxon_names FOR EACH ROW EXECUTE PROCEDURE trg_taxon_names_u();


--
-- Name: trg_taxon_relationships_d; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_relationships_d AFTER DELETE ON taxon_relationships FOR EACH ROW EXECUTE PROCEDURE trg_taxon_relationships_d();


--
-- Name: trg_taxon_relationships_ui; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_taxon_relationships_ui AFTER INSERT OR UPDATE ON taxon_relationships FOR EACH ROW EXECUTE PROCEDURE trg_taxon_relationships_ui();


--
-- Name: annotation_translations_annotation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotation_translations
    ADD CONSTRAINT annotation_translations_annotation_id_fk FOREIGN KEY (annotation_id) REFERENCES annotations(id);


--
-- Name: annotation_translations_language_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotation_translations
    ADD CONSTRAINT annotation_translations_language_id_fk FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: annotations_listing_changes_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_listing_changes_id_fk FOREIGN KEY (listing_change_id) REFERENCES listing_changes(id);


--
-- Name: change_types_designation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY change_types
    ADD CONSTRAINT change_types_designation_id_fk FOREIGN KEY (designation_id) REFERENCES designations(id);


--
-- Name: common_names_language_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY common_names
    ADD CONSTRAINT common_names_language_id_fk FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: designations_taxonomy_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY designations
    ADD CONSTRAINT designations_taxonomy_id_fk FOREIGN KEY (taxonomy_id) REFERENCES taxonomies(id);


--
-- Name: geo_entities_geo_entity_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_entities
    ADD CONSTRAINT geo_entities_geo_entity_type_id_fk FOREIGN KEY (geo_entity_type_id) REFERENCES geo_entity_types(id);


--
-- Name: geo_relationships_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationships
    ADD CONSTRAINT geo_relationships_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: geo_relationships_geo_relationship_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationships
    ADD CONSTRAINT geo_relationships_geo_relationship_type_id_fk FOREIGN KEY (geo_relationship_type_id) REFERENCES geo_relationship_types(id);


--
-- Name: geo_relationships_other_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY geo_relationships
    ADD CONSTRAINT geo_relationships_other_geo_entity_id_fk FOREIGN KEY (other_geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: listing_changes_annotation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_annotation_id_fk FOREIGN KEY (annotation_id) REFERENCES annotations(id);


--
-- Name: listing_changes_change_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_change_type_id_fk FOREIGN KEY (change_type_id) REFERENCES change_types(id);


--
-- Name: listing_changes_hash_annotation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_hash_annotation_id_fk FOREIGN KEY (annotation_id) REFERENCES annotations(id);


--
-- Name: listing_changes_inclusion_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_inclusion_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: listing_changes_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_parent_id_fk FOREIGN KEY (parent_id) REFERENCES listing_changes(id);


--
-- Name: listing_changes_species_listing_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_species_listing_id_fk FOREIGN KEY (species_listing_id) REFERENCES species_listings(id);


--
-- Name: listing_changes_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: listing_distributions_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_distributions
    ADD CONSTRAINT listing_distributions_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: listing_distributions_listing_change_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_distributions
    ADD CONSTRAINT listing_distributions_listing_change_id_fk FOREIGN KEY (listing_change_id) REFERENCES listing_changes(id);


--
-- Name: species_listings_designation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY species_listings
    ADD CONSTRAINT species_listings_designation_id_fk FOREIGN KEY (designation_id) REFERENCES designations(id);


--
-- Name: taxon_commons_common_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_commons
    ADD CONSTRAINT taxon_commons_common_name_id_fk FOREIGN KEY (common_name_id) REFERENCES common_names(id);


--
-- Name: taxon_commons_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_commons
    ADD CONSTRAINT taxon_commons_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_concept_geo_entities_geo_entity_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT taxon_concept_geo_entities_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: taxon_concept_geo_entities_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distributions
    ADD CONSTRAINT taxon_concept_geo_entities_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_concept_geo_entity_references_reference_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distribution_references
    ADD CONSTRAINT taxon_concept_geo_entity_references_reference_id_fk FOREIGN KEY (reference_id) REFERENCES "references"(id);


--
-- Name: taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY distribution_references
    ADD CONSTRAINT taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk FOREIGN KEY (distribution_id) REFERENCES distributions(id);


--
-- Name: taxon_concept_references_reference_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_references
    ADD CONSTRAINT taxon_concept_references_reference_id_fk FOREIGN KEY (reference_id) REFERENCES "references"(id);


--
-- Name: taxon_concept_references_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_references
    ADD CONSTRAINT taxon_concept_references_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_concepts_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_parent_id_fk FOREIGN KEY (parent_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_concepts_rank_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_rank_id_fk FOREIGN KEY (rank_id) REFERENCES ranks(id);


--
-- Name: taxon_concepts_taxon_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_taxon_name_id_fk FOREIGN KEY (taxon_name_id) REFERENCES taxon_names(id);


--
-- Name: taxon_concepts_taxonomy_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_taxonomy_id_fk FOREIGN KEY (taxonomy_id) REFERENCES taxonomies(id);


--
-- Name: taxon_relationships_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationships
    ADD CONSTRAINT taxon_relationships_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_relationships_taxon_relationship_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationships
    ADD CONSTRAINT taxon_relationships_taxon_relationship_type_id_fk FOREIGN KEY (taxon_relationship_type_id) REFERENCES taxon_relationship_types(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20120530135534');

INSERT INTO schema_migrations (version) VALUES ('20120703141230');

INSERT INTO schema_migrations (version) VALUES ('20121004124446');

INSERT INTO schema_migrations (version) VALUES ('20130115195233');

INSERT INTO schema_migrations (version) VALUES ('20130122143207');

INSERT INTO schema_migrations (version) VALUES ('20130128111252');

INSERT INTO schema_migrations (version) VALUES ('20130128112003');

INSERT INTO schema_migrations (version) VALUES ('20130128152811');

INSERT INTO schema_migrations (version) VALUES ('20130128153000');

INSERT INTO schema_migrations (version) VALUES ('20130128153040');

INSERT INTO schema_migrations (version) VALUES ('20130128155000');

INSERT INTO schema_migrations (version) VALUES ('20130129090244');

INSERT INTO schema_migrations (version) VALUES ('20130129094005');

INSERT INTO schema_migrations (version) VALUES ('20130130120328');

INSERT INTO schema_migrations (version) VALUES ('20130131140309');

INSERT INTO schema_migrations (version) VALUES ('20130131140448');

INSERT INTO schema_migrations (version) VALUES ('20130208105720');

INSERT INTO schema_migrations (version) VALUES ('20130211152507');

INSERT INTO schema_migrations (version) VALUES ('20130211155326');

INSERT INTO schema_migrations (version) VALUES ('20130212105758');

INSERT INTO schema_migrations (version) VALUES ('20130212110108');

INSERT INTO schema_migrations (version) VALUES ('20130212115631');

INSERT INTO schema_migrations (version) VALUES ('20130212115937');

INSERT INTO schema_migrations (version) VALUES ('20130212181445');

INSERT INTO schema_migrations (version) VALUES ('20130218131528');