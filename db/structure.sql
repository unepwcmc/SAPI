--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

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


SET search_path = public, pg_catalog;

--
-- Name: fix_cites_listing_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION fix_cites_listing_changes() RETURNS void
    LANGUAGE plpgsql
    AS $$
      BEGIN
      INSERT INTO listing_changes 
      (taxon_concept_id, species_listing_id, change_type_id, effective_at, created_at, updated_at)
      SELECT 
      qq.taxon_concept_id, qq.species_listing_id, (SELECT id FROM change_types WHERE name = 'DELETION' LIMIT 1),
      qq.effective_at - time '00:00:01', NOW(), NOW()
      FROM (
                    WITH q AS (
                        SELECT listing_changes.id AS id, taxon_concept_id, species_listing_id, change_type_id,
                             effective_at, change_types.name AS change_type_name,
                             species_listings.abbreviation AS listing_name,
                             listing_distributions.geo_entity_id AS party_id, geo_entities_ary,
                             ROW_NUMBER() OVER(ORDER BY taxon_concept_id, effective_at) AS row_no
                             FROM
                             listing_changes
                             LEFT JOIN change_types ON change_type_id = change_types.id
                             LEFT JOIN species_listings ON species_listing_id = species_listings.id
                             LEFT JOIN designations ON designations.id = species_listings.designation_id
                             LEFT JOIN listing_distributions ON listing_changes.id = listing_distributions.listing_change_id
                               AND listing_distributions.is_party = 't'
                             LEFT JOIN (
                               SELECT listing_change_id, ARRAY_AGG(geo_entity_id) AS geo_entities_ary
                               FROM listing_distributions
                               WHERE listing_distributions.is_party <> 't'
                               GROUP BY listing_change_id
                             ) listing_distributions_agr ON listing_distributions_agr.listing_change_id = listing_changes.id
                             WHERE change_types.name IN ('ADDITION','DELETION')
                             AND designations.name = 'CITES'
                     )
                     SELECT q1.taxon_concept_id, q1.species_listing_id, q2.effective_at
                     FROM q q1 LEFT JOIN q q2 ON (q1.taxon_concept_id = q2.taxon_concept_id AND q2.row_no = q1.row_no + 1)
                     WHERE q2.taxon_concept_id IS NOT NULL
                     -- only add a deletion record between two additiona records
                     AND q1.change_type_id = q2.change_type_id AND q1.change_type_name = 'ADDITION'
                     -- do not add between consecutive app III additions by different countries
                     AND NOT (q1.listing_name = 'III' AND q2.listing_name = 'III' AND q1.party_id <> q2.party_id)
                     -- do not add between additions entered on the same day
                     AND NOT (q1.effective_at = q2.effective_at)
                     -- do not add between additions to different appendices where the distribution is different
                     AND NOT (
                     --q1.species_listing_id <> q2.species_listing_id
                     --  AND (
                         q1.geo_entities_ary IS NOT NULL AND q2.geo_entities_ary IS NOT NULL
                           AND q1.geo_entities_ary <> q2.geo_entities_ary
                         OR
                         q1.geo_entities_ary IS NULL AND q2.geo_entities_ary IS NOT NULL
                         OR
                         q2.geo_entities_ary IS NULL AND q1.geo_entities_ary IS NOT NULL
                     --  )
                     )
      ) qq;
      END;
      $$;


--
-- Name: FUNCTION fix_cites_listing_changes(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION fix_cites_listing_changes() IS 'Procedure to insert deletions between any two additions to appendices for a given taxon_concept.';


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
            hstore('not_in_cites', MAX((listing -> 'not_in_cites')::VARCHAR)) ||
            hstore('cites_listing', ARRAY_TO_STRING(
              -- unnest to filter out the nulls
              ARRAY(SELECT * FROM UNNEST(
                ARRAY[
                  MAX((listing -> 'cites_I')::VARCHAR),
                  MAX((listing -> 'cites_II')::VARCHAR),
                  MAX((listing -> 'cites_III')::VARCHAR),
                  MAX((listing -> 'not_in_cites')::VARCHAR)
                ]) s WHERE s IS NOT NULL),
                '/'
              )
            ) AS listing
            FROM q 
            GROUP BY (id)
          )
          UPDATE taxon_concepts
          SET listing = 
            CASE
            WHEN taxon_concepts.listing IS NOT NULL THEN taxon_concepts.listing
            ELSE ''::hstore
            END || qq.listing
          FROM qq
          WHERE taxon_concepts.id = qq.id;

        END;
      $$;


--
-- Name: FUNCTION rebuild_ancestor_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_ancestor_listings() IS 'Procedure to rebuild the computed ancestor listings in taxon_concepts.';


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
            ELSE data - ARRAY['cites_accepted']
          END || hstore('cites_accepted', NULL);

        -- set the cites_accepted flag to true for all explicitly referenced taxa
        UPDATE taxon_concepts
        SET data = data || hstore('cites_accepted', 't')
        FROM (
          SELECT taxon_concepts.id
          FROM taxon_concepts
          INNER JOIN taxon_concept_references
            ON taxon_concept_references.taxon_concept_id = taxon_concepts.id
          INNER JOIN designations ON taxon_concepts.designation_id = designations.id
          WHERE designations.name = 'CITES' AND (taxon_concept_references.data->'usr_is_std_ref')::BOOLEAN = 't'
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
          INNER JOIN designations
            ON designations.id = taxon_concepts.designation_id
          WHERE designations.name = 'CITES'
            AND taxon_relationship_types.name = 'HAS_SYNONYM'
        ) AS q
        WHERE taxon_concepts.id = q.id;

        -- set the cites_accepted flag to true for all implicitly listed taxa
        WITH RECURSIVE q AS
        (
          SELECT  h,
            CASE
              WHEN (data->'usr_no_std_ref')::BOOLEAN = 't' THEN 'f'
              ELSE (data->'cites_accepted')::BOOLEAN
            END AS inherited_cites_accepted
          FROM    taxon_concepts h
          WHERE   parent_id IS NULL

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
        SET data = data || hstore('cites_accepted', 't')
        FROM q
        WHERE taxon_concepts.id = (q.h).id AND
          ((q.h).data->'cites_accepted')::BOOLEAN IS NULL
          AND inherited_cites_accepted = 't';

        END;
      $$;


--
-- Name: FUNCTION rebuild_cites_accepted_flags(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_cites_accepted_flags() IS 'Procedure to rebuild the cites_accepted flag in taxon_concepts.data. The meaning of this flag is as follows: "t" - CITES accepted name, "f" - not accepted, but shows in Checklist, null - not accepted, doesn''t show';


--
-- Name: rebuild_cites_listed_flags(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_cites_listed_flags() RETURNS void
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


--
-- Name: rebuild_descendant_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_descendant_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
          WITH RECURSIVE q AS (
            SELECT h, id, listing
            FROM taxon_concepts h
            WHERE parent_id IS NULL

            UNION ALL

            SELECT hi, hi.id, CASE
              WHEN
                hi.listing -> 'cites_listed' ='t'
                OR hi.listing->'cites_exclusion' = 't'
                THEN hi.listing || hstore('cites_listing',hi.listing->'cites_listing_original')
              ELSE hi.listing || (q.listing::hstore - ARRAY['cites_listed','cites_listing_original'])
                || hstore('cites_listing',q.listing->'cites_listing_original')
            END
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
          )
          UPDATE taxon_concepts
          SET listing = 
          CASE
            WHEN taxon_concepts.listing IS NULL THEN ''::hstore
            ELSE taxon_concepts.listing
          END || q.listing
          FROM q
          WHERE taxon_concepts.id = q.id;
        END;
      $$;


--
-- Name: FUNCTION rebuild_descendant_listings(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_descendant_listings() IS 'Procedure to rebuild the computed descendant listings in taxon_concepts.';


--
-- Name: rebuild_listings(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_listings() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN

        UPDATE taxon_concepts
        SET listing = taxon_concepts.listing || qqq.listing ||
        CASE
          WHEN qqq.listing -> 'cites_listing_original' > '' THEN hstore('cites_show', 't')
          ELSE hstore('cites_show', 'f')
        END
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
              LEFT JOIN species_listings ON species_listing_id = species_listings.id
              LEFT JOIN change_types ON change_type_id = change_types.id
              AND change_types.name IN ('ADDITION','DELETION')
              AND effective_at <= NOW()
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
-- Name: rebuild_names_and_ranks(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_names_and_ranks() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
	  UPDATE taxon_concepts SET data = ''::HSTORE WHERE data IS NULL;

          WITH RECURSIVE q AS (
            SELECT h, h.id, ranks.name as rank_name,
            hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name) AS ancestors
            FROM taxon_concepts h
            INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
            INNER JOIN ranks ON h.rank_id = ranks.id
            WHERE h.parent_id IS NULL

            UNION ALL

            SELECT hi, hi.id, ranks.name,
            ancestors || hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name)
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
            INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
            INNER JOIN ranks ON hi.rank_id = ranks.id
          )
          UPDATE taxon_concepts
          SET data = data || ancestors || hstore('full_name',
            CASE
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
            END
          ) || hstore('rank_name', rank_name)
          FROM q
          WHERE taxon_concepts.id = q.id;
        END;
      $$;


--
-- Name: FUNCTION rebuild_names_and_ranks(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_names_and_ranks() IS 'Procedure to rebuild the computed full name, rank and ancestor names fields in taxon_concepts.';


--
-- Name: rebuild_taxonomic_positions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION rebuild_taxonomic_positions() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
        -- delete results of previous computations
        UPDATE taxon_concepts
        SET data = data || hstore('taxonomic_position', NULL)
        WHERE length(data->'taxonomic_position') > 5;
        WITH RECURSIVE q AS (
          SELECT h, id,
          data->'taxonomic_position' AS taxonomic_position
          FROM taxon_concepts h
          WHERE parent_id IS NULL

          UNION ALL

          SELECT hi, hi.id,
          CASE
            WHEN CAST(data -> 'taxonomic_position' AS VARCHAR) IS NOT NULL THEN data -> 'taxonomic_position'
            -- use generous zero padding to accommodate for orchidacea (30 thousand species in about 900 genera)
            ELSE q.taxonomic_position || '.' || LPAD(
              CAST(row_number() OVER (PARTITION BY parent_id ORDER BY data->'full_name') AS VARCHAR),
              5,
              '0'
            )
          END
        
          FROM q
          JOIN    taxon_concepts hi
          ON      hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET data = CASE
          WHEN data IS NULL THEN hstore('taxonomic_position', taxonomic_position)
          ELSE data || hstore('taxonomic_position', taxonomic_position) END
        FROM q
        WHERE q.id = taxon_concepts.id;
        END;
      $$;


--
-- Name: FUNCTION rebuild_taxonomic_positions(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_taxonomic_positions() IS 'Procedure to rebuild the computed taxonomic position fields in taxon_concepts.';


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
          PERFORM rebuild_cites_listed_flags();
          --RAISE NOTICE 'listings';
          PERFORM rebuild_listings();
          --RAISE NOTICE 'descendant listings';
          PERFORM rebuild_descendant_listings();
          --RAISE NOTICE 'ancestor listings';
          PERFORM rebuild_ancestor_listings();
          PERFORM rebuild_cites_accepted_flags();
        END;
      $$;


--
-- Name: FUNCTION sapi_rebuild(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION sapi_rebuild() IS 'Procedure to rebuild computed fields in the database.';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: change_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE change_types (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    designation_id integer NOT NULL
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
-- Name: common_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE common_names (
    id integer NOT NULL,
    name character varying(255),
    reference_id integer,
    language_id integer,
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
-- Name: designations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE designations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: geo_entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE geo_entities (
    id integer NOT NULL,
    geo_entity_type_id integer NOT NULL,
    name character varying(255) NOT NULL,
    long_name character varying(255),
    iso_code2 character varying(255),
    iso_code3 character varying(255),
    legacy_id integer,
    legacy_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    name character varying(255),
    abbreviation character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    species_listing_id integer,
    taxon_concept_id integer,
    change_type_id integer,
    reference_id integer,
    lft integer,
    rgt integer,
    parent_id integer,
    depth integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    effective_at timestamp without time zone DEFAULT '2012-08-17 14:48:33.751384'::timestamp without time zone NOT NULL,
    notes text
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
-- Name: listing_distributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE listing_distributions (
    id integer NOT NULL,
    listing_change_id integer NOT NULL,
    geo_entity_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_party boolean DEFAULT true NOT NULL
);


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
    parent_id integer,
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
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    author character varying(255),
    legacy_id integer,
    legacy_type character varying(255)
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
-- Name: species_listings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE species_listings (
    id integer NOT NULL,
    designation_id integer,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    abbreviation character varying(255)
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
-- Name: taxon_commons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_commons (
    id integer NOT NULL,
    taxon_concept_id integer,
    common_name_id integer,
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
-- Name: taxon_concept_geo_entities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concept_geo_entities (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    geo_entity_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_concept_geo_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_concept_geo_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_concept_geo_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_concept_geo_entities_id_seq OWNED BY taxon_concept_geo_entities.id;


--
-- Name: taxon_concept_geo_entity_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concept_geo_entity_references (
    id integer NOT NULL,
    taxon_concept_geo_entity_id integer,
    reference_id integer
);


--
-- Name: taxon_concept_geo_entity_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_concept_geo_entity_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_concept_geo_entity_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_concept_geo_entity_references_id_seq OWNED BY taxon_concept_geo_entity_references.id;


--
-- Name: taxon_concept_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_concept_references (
    id integer NOT NULL,
    taxon_concept_id integer NOT NULL,
    reference_id integer NOT NULL,
    data hstore DEFAULT ''::hstore NOT NULL
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
    lft integer,
    rgt integer,
    rank_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    depth integer,
    designation_id integer NOT NULL,
    taxon_name_id integer NOT NULL,
    legacy_id integer,
    inherit_distribution boolean DEFAULT true NOT NULL,
    data hstore DEFAULT ''::hstore,
    fully_covered boolean DEFAULT true NOT NULL,
    listing hstore
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
-- Name: taxon_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_names (
    id integer NOT NULL,
    scientific_name character varying(255) NOT NULL,
    basionym_id integer,
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

ALTER TABLE ONLY taxon_commons ALTER COLUMN id SET DEFAULT nextval('taxon_commons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_geo_entities ALTER COLUMN id SET DEFAULT nextval('taxon_concept_geo_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_geo_entity_references ALTER COLUMN id SET DEFAULT nextval('taxon_concept_geo_entity_references_id_seq'::regclass);


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
-- Name: taxon_commons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_commons
    ADD CONSTRAINT taxon_commons_pkey PRIMARY KEY (id);


--
-- Name: taxon_concept_geo_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_concept_geo_entities
    ADD CONSTRAINT taxon_concept_geo_entities_pkey PRIMARY KEY (id);


--
-- Name: taxon_concept_geo_entity_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_concept_geo_entity_references
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
-- Name: index_taxon_concepts_on_data; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_data ON taxon_concepts USING btree (data);


--
-- Name: index_taxon_concepts_on_lft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_lft ON taxon_concepts USING btree (lft);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


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
-- Name: listing_changes_change_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_change_type_id_fk FOREIGN KEY (change_type_id) REFERENCES change_types(id);


--
-- Name: listing_changes_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_parent_id_fk FOREIGN KEY (parent_id) REFERENCES listing_changes(id);


--
-- Name: listing_changes_reference_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_reference_id_fk FOREIGN KEY (reference_id) REFERENCES "references"(id);


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
-- Name: ranks_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ranks
    ADD CONSTRAINT ranks_parent_id_fk FOREIGN KEY (parent_id) REFERENCES ranks(id);


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

ALTER TABLE ONLY taxon_concept_geo_entities
    ADD CONSTRAINT taxon_concept_geo_entities_geo_entity_id_fk FOREIGN KEY (geo_entity_id) REFERENCES geo_entities(id);


--
-- Name: taxon_concept_geo_entities_taxon_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_geo_entities
    ADD CONSTRAINT taxon_concept_geo_entities_taxon_concept_id_fk FOREIGN KEY (taxon_concept_id) REFERENCES taxon_concepts(id);


--
-- Name: taxon_concept_geo_entity_references_reference_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_geo_entity_references
    ADD CONSTRAINT taxon_concept_geo_entity_references_reference_id_fk FOREIGN KEY (reference_id) REFERENCES "references"(id);


--
-- Name: taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concept_geo_entity_references
    ADD CONSTRAINT taxon_concept_geo_entity_references_taxon_concept_geo_entity_fk FOREIGN KEY (taxon_concept_geo_entity_id) REFERENCES taxon_concept_geo_entities(id);


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
-- Name: taxon_concepts_designation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_designation_id_fk FOREIGN KEY (designation_id) REFERENCES designations(id);


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
-- Name: taxon_names_basionym_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_names
    ADD CONSTRAINT taxon_names_basionym_id_fk FOREIGN KEY (basionym_id) REFERENCES taxon_names(id);


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

INSERT INTO schema_migrations (version) VALUES ('20120525074930');

INSERT INTO schema_migrations (version) VALUES ('20120530125027');

INSERT INTO schema_migrations (version) VALUES ('20120530135534');

INSERT INTO schema_migrations (version) VALUES ('20120530135535');

INSERT INTO schema_migrations (version) VALUES ('20120530135832');

INSERT INTO schema_migrations (version) VALUES ('20120531091826');

INSERT INTO schema_migrations (version) VALUES ('20120606074358');

INSERT INTO schema_migrations (version) VALUES ('20120606125349');

INSERT INTO schema_migrations (version) VALUES ('20120606131036');

INSERT INTO schema_migrations (version) VALUES ('20120606132104');

INSERT INTO schema_migrations (version) VALUES ('20120607073043');

INSERT INTO schema_migrations (version) VALUES ('20120607132022');

INSERT INTO schema_migrations (version) VALUES ('20120607143941');

INSERT INTO schema_migrations (version) VALUES ('20120608151332');

INSERT INTO schema_migrations (version) VALUES ('20120611081843');

INSERT INTO schema_migrations (version) VALUES ('20120613124612');

INSERT INTO schema_migrations (version) VALUES ('20120613152325');

INSERT INTO schema_migrations (version) VALUES ('20120613152427');

INSERT INTO schema_migrations (version) VALUES ('20120613152604');

INSERT INTO schema_migrations (version) VALUES ('20120615120151');

INSERT INTO schema_migrations (version) VALUES ('20120615121349');

INSERT INTO schema_migrations (version) VALUES ('20120615122741');

INSERT INTO schema_migrations (version) VALUES ('20120615141606');

INSERT INTO schema_migrations (version) VALUES ('20120617222553');

INSERT INTO schema_migrations (version) VALUES ('20120618070625');

INSERT INTO schema_migrations (version) VALUES ('20120618105456');

INSERT INTO schema_migrations (version) VALUES ('20120618132628');

INSERT INTO schema_migrations (version) VALUES ('20120618143304');

INSERT INTO schema_migrations (version) VALUES ('20120619081335');

INSERT INTO schema_migrations (version) VALUES ('20120619095737');

INSERT INTO schema_migrations (version) VALUES ('20120619100341');

INSERT INTO schema_migrations (version) VALUES ('20120619102316');

INSERT INTO schema_migrations (version) VALUES ('20120619121756');

INSERT INTO schema_migrations (version) VALUES ('20120619123910');

INSERT INTO schema_migrations (version) VALUES ('20120619124109');

INSERT INTO schema_migrations (version) VALUES ('20120619145616');

INSERT INTO schema_migrations (version) VALUES ('20120620071138');

INSERT INTO schema_migrations (version) VALUES ('20120620145200');

INSERT INTO schema_migrations (version) VALUES ('20120622143404');

INSERT INTO schema_migrations (version) VALUES ('20120626140446');

INSERT INTO schema_migrations (version) VALUES ('20120627120930');

INSERT INTO schema_migrations (version) VALUES ('20120627133057');

INSERT INTO schema_migrations (version) VALUES ('20120628072610');

INSERT INTO schema_migrations (version) VALUES ('20120628082509');

INSERT INTO schema_migrations (version) VALUES ('20120628085124');

INSERT INTO schema_migrations (version) VALUES ('20120628085253');

INSERT INTO schema_migrations (version) VALUES ('20120628123444');

INSERT INTO schema_migrations (version) VALUES ('20120628145332');

INSERT INTO schema_migrations (version) VALUES ('20120629090125');

INSERT INTO schema_migrations (version) VALUES ('20120702072151');

INSERT INTO schema_migrations (version) VALUES ('20120702072355');

INSERT INTO schema_migrations (version) VALUES ('20120702073119');

INSERT INTO schema_migrations (version) VALUES ('20120703074243');

INSERT INTO schema_migrations (version) VALUES ('20120703075419');

INSERT INTO schema_migrations (version) VALUES ('20120703141230');

INSERT INTO schema_migrations (version) VALUES ('20120704095341');

INSERT INTO schema_migrations (version) VALUES ('20120712135238');

INSERT INTO schema_migrations (version) VALUES ('20120725132210');

INSERT INTO schema_migrations (version) VALUES ('20120727144007');

INSERT INTO schema_migrations (version) VALUES ('20120801134301');

INSERT INTO schema_migrations (version) VALUES ('20120807105444');

INSERT INTO schema_migrations (version) VALUES ('20120807115736');

INSERT INTO schema_migrations (version) VALUES ('20120807115924');

INSERT INTO schema_migrations (version) VALUES ('20120807120807');

INSERT INTO schema_migrations (version) VALUES ('20120807121035');

INSERT INTO schema_migrations (version) VALUES ('20120807122112');

INSERT INTO schema_migrations (version) VALUES ('20120808074811');

INSERT INTO schema_migrations (version) VALUES ('20120808125231');

INSERT INTO schema_migrations (version) VALUES ('20120808131608');

INSERT INTO schema_migrations (version) VALUES ('20120808134006');

INSERT INTO schema_migrations (version) VALUES ('20120809084541');

INSERT INTO schema_migrations (version) VALUES ('20120809141929');

INSERT INTO schema_migrations (version) VALUES ('20120810084818');

INSERT INTO schema_migrations (version) VALUES ('20120810101954');

INSERT INTO schema_migrations (version) VALUES ('20120810102226');

INSERT INTO schema_migrations (version) VALUES ('20120810145423');

INSERT INTO schema_migrations (version) VALUES ('20120814102042');