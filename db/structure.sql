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
    updated_at timestamp without time zone NOT NULL
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
    updated_at timestamp without time zone NOT NULL
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
    symbol character varying(255),
    parent_symbol character varying(255),
    generic_english_full_note text,
    generic_spanish_full_note text,
    generic_french_full_note text,
    english_full_note text,
    spanish_full_note text,
    french_full_note text,
    english_short_note text,
    spanish_short_note text,
    french_short_note text,
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
    WITH multilingual_annotations AS (SELECT ct.annotation_id_mul, ct.english_note[1] AS english_full_note, ct.english_note[2] AS english_short_note, ct.spanish_note[1] AS spanish_full_note, ct.spanish_note[2] AS spanish_short_note, ct.french_note[1] AS french_full_note, ct.french_note[2] AS french_short_note FROM crosstab('SELECT annotations.id AS annotation_id_mul,
        SUBSTRING(languages.name_en FROM 1 FOR 1) AS lng,
        ARRAY[annotation_translations.full_note, annotation_translations.short_note]
        FROM "annotations"
        INNER JOIN "annotation_translations"
          ON "annotation_translations"."annotation_id" = "annotations"."id" 
        INNER JOIN "languages"
          ON "languages"."id" = "annotation_translations"."language_id"
        ORDER BY 1,2'::text) ct(annotation_id_mul integer, english_note text[], spanish_note text[], french_note text[])) SELECT listing_changes.id, listing_changes.taxon_concept_id, listing_changes.effective_at, listing_changes.species_listing_id, species_listings.abbreviation AS species_listing_name, listing_changes.change_type_id, change_types.name AS change_type_name, listing_distributions.geo_entity_id AS party_id, geo_entities.iso_code2 AS party_name, generic_annotations.symbol, generic_annotations.parent_symbol, multilingual_generic_annotations.english_full_note AS generic_english_full_note, multilingual_generic_annotations.spanish_full_note AS generic_spanish_full_note, multilingual_generic_annotations.french_full_note AS generic_french_full_note, multilingual_specific_annotations.english_full_note, multilingual_specific_annotations.spanish_full_note, multilingual_specific_annotations.french_full_note, multilingual_specific_annotations.english_short_note, multilingual_specific_annotations.spanish_short_note, multilingual_specific_annotations.french_short_note, listing_changes.is_current, populations.countries_ids_ary FROM (((((((((listing_changes LEFT JOIN change_types ON ((listing_changes.change_type_id = change_types.id))) LEFT JOIN species_listings ON ((listing_changes.species_listing_id = species_listings.id))) LEFT JOIN listing_distributions ON (((listing_changes.id = listing_distributions.listing_change_id) AND (listing_distributions.is_party = true)))) LEFT JOIN geo_entities ON ((geo_entities.id = listing_distributions.geo_entity_id))) LEFT JOIN annotations specific_annotations ON ((specific_annotations.listing_change_id = listing_changes.id))) LEFT JOIN annotations generic_annotations ON ((generic_annotations.id = listing_changes.annotation_id))) LEFT JOIN multilingual_annotations multilingual_specific_annotations ON ((specific_annotations.id = multilingual_specific_annotations.annotation_id_mul))) LEFT JOIN multilingual_annotations multilingual_generic_annotations ON ((generic_annotations.id = multilingual_generic_annotations.annotation_id_mul))) LEFT JOIN (SELECT listing_distributions.listing_change_id, array_agg(geo_entities.id) AS countries_ids_ary FROM (listing_distributions JOIN geo_entities ON ((geo_entities.id = listing_distributions.geo_entity_id))) WHERE (NOT listing_distributions.is_party) GROUP BY listing_distributions.listing_change_id) populations ON ((populations.listing_change_id = listing_changes.id))) ORDER BY listing_changes.taxon_concept_id, listing_changes.effective_at, CASE WHEN ((change_types.name)::text = 'ADDITION'::text) THEN 0 WHEN ((change_types.name)::text = 'RESERVATION'::text) THEN 1 WHEN ((change_types.name)::text = 'RESERVATION_WITHDRAWAL'::text) THEN 2 WHEN ((change_types.name)::text = 'DELETION'::text) THEN 3 ELSE NULL::integer END;


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
    specific_annotation_symbol text,
    generic_annotation_symbol text,
    generic_annotation_parent_symbol text,
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
    specific_annotation_symbol text,
    generic_annotation_symbol text,
    generic_annotation_parent_symbol text,
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

CREATE RULE "_RETURN" AS ON SELECT TO taxon_concepts_view DO INSTEAD SELECT taxon_concepts.id, taxon_concepts.parent_id, CASE WHEN ((taxonomies.name)::text = 'CITES_EU'::text) THEN true ELSE false END AS taxonomy_is_cites_eu, taxon_concepts.full_name, taxon_concepts.name_status, (taxon_concepts.data -> 'rank_name'::text) AS rank_name, ((taxon_concepts.data -> 'cites_accepted'::text))::boolean AS cites_accepted, CASE WHEN ((taxon_concepts.data -> 'kingdom_name'::text) = 'Animalia'::text) THEN 0 ELSE 1 END AS kingdom_position, taxon_concepts.taxonomic_position, (taxon_concepts.data -> 'kingdom_name'::text) AS kingdom_name, (taxon_concepts.data -> 'phylum_name'::text) AS phylum_name, (taxon_concepts.data -> 'class_name'::text) AS class_name, (taxon_concepts.data -> 'order_name'::text) AS order_name, (taxon_concepts.data -> 'family_name'::text) AS family_name, (taxon_concepts.data -> 'genus_name'::text) AS genus_name, (taxon_concepts.data -> 'species_name'::text) AS species_name, (taxon_concepts.data -> 'subspecies_name'::text) AS subspecies_name, ((taxon_concepts.data -> 'kingdom_id'::text))::integer AS kingdom_id, ((taxon_concepts.data -> 'phylum_id'::text))::integer AS phylum_id, ((taxon_concepts.data -> 'class_id'::text))::integer AS class_id, ((taxon_concepts.data -> 'order_id'::text))::integer AS order_id, ((taxon_concepts.data -> 'family_id'::text))::integer AS family_id, ((taxon_concepts.data -> 'genus_id'::text))::integer AS genus_id, ((taxon_concepts.data -> 'species_id'::text))::integer AS species_id, ((taxon_concepts.data -> 'subspecies_id'::text))::integer AS subspecies_id, ((taxon_concepts.listing -> 'cites_fully_covered'::text))::boolean AS cites_fully_covered, CASE WHEN (((taxon_concepts.listing -> 'cites_status'::text) = 'LISTED'::text) AND ((taxon_concepts.listing -> 'cites_status_original'::text) = 't'::text)) THEN true WHEN ((taxon_concepts.listing -> 'cites_status'::text) = 'LISTED'::text) THEN false ELSE NULL::boolean END AS cites_listed, CASE WHEN ((taxon_concepts.listing -> 'cites_status'::text) = 'DELETED'::text) THEN true ELSE false END AS cites_deleted, CASE WHEN ((taxon_concepts.listing -> 'cites_status'::text) = 'EXCLUDED'::text) THEN true ELSE false END AS cites_excluded, ((taxon_concepts.listing -> 'cites_show'::text))::boolean AS cites_show, CASE WHEN ((taxon_concepts.listing -> 'cites_I'::text) = 'I'::text) THEN true ELSE false END AS cites_i, CASE WHEN ((taxon_concepts.listing -> 'cites_II'::text) = 'II'::text) THEN true ELSE false END AS cites_ii, CASE WHEN ((taxon_concepts.listing -> 'cites_III'::text) = 'III'::text) THEN true ELSE false END AS cites_iii, (taxon_concepts.listing -> 'cites_listing'::text) AS current_listing, ((taxon_concepts.listing -> 'listing_updated_at'::text))::timestamp without time zone AS listing_updated_at, (taxon_concepts.listing -> 'specific_annotation_symbol'::text) AS specific_annotation_symbol, (taxon_concepts.listing -> 'generic_annotation_symbol'::text) AS generic_annotation_symbol, (taxon_concepts.listing -> 'generic_annotation_parent_symbol'::text) AS generic_annotation_parent_symbol, taxon_concepts.author_year, taxon_concepts.created_at, taxon_concepts.updated_at, common_names.taxon_concept_id_com, common_names.english_names_ary, common_names.french_names_ary, common_names.spanish_names_ary, synonyms.taxon_concept_id_syn, synonyms.synonyms_ary, synonyms.synonyms_author_years_ary, countries_ids.countries_ids_ary, standard_references_ids.standard_references_ids_ary FROM (((((taxon_concepts LEFT JOIN taxonomies ON ((taxonomies.id = taxon_concepts.taxonomy_id))) LEFT JOIN (SELECT ct.taxon_concept_id_com, ct.english_names_ary, ct.french_names_ary, ct.spanish_names_ary FROM crosstab('SELECT taxon_concepts.id AS taxon_concept_id_com,
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
    ORDER BY 1,2'::text) ct(taxon_concept_id_com integer, english_names_ary character varying[], french_names_ary character varying[], spanish_names_ary character varying[])) common_names ON ((taxon_concepts.id = common_names.taxon_concept_id_com))) LEFT JOIN (SELECT taxon_concepts.id AS taxon_concept_id_syn, array_agg(synonym_tc.full_name) AS synonyms_ary, array_agg(synonym_tc.author_year) AS synonyms_author_years_ary FROM (((taxon_concepts LEFT JOIN taxon_relationships ON ((taxon_relationships.taxon_concept_id = taxon_concepts.id))) LEFT JOIN taxon_relationship_types ON ((taxon_relationship_types.id = taxon_relationships.taxon_relationship_type_id))) LEFT JOIN taxon_concepts synonym_tc ON ((synonym_tc.id = taxon_relationships.other_taxon_concept_id))) GROUP BY taxon_concepts.id) synonyms ON ((taxon_concepts.id = synonyms.taxon_concept_id_syn))) LEFT JOIN (SELECT taxon_concepts.id AS taxon_concept_id_cnt, array_agg(geo_entities.id ORDER BY geo_entities.name_en) AS countries_ids_ary FROM (((taxon_concepts LEFT JOIN distributions taxon_concept_geo_entities ON ((taxon_concept_geo_entities.taxon_concept_id = taxon_concepts.id))) LEFT JOIN geo_entities ON ((taxon_concept_geo_entities.geo_entity_id = geo_entities.id))) LEFT JOIN geo_entity_types ON (((geo_entity_types.id = geo_entities.geo_entity_type_id) AND ((geo_entity_types.name)::text = 'COUNTRY'::text)))) GROUP BY taxon_concepts.id) countries_ids ON ((taxon_concepts.id = countries_ids.taxon_concept_id_cnt))) LEFT JOIN (WITH taxa_with_std_refs AS (WITH RECURSIVE q AS (SELECT h.*::taxon_concepts AS h, h.id, array_agg(taxon_concept_references.reference_id) AS standard_references_ids_ary FROM (taxon_concepts h LEFT JOIN taxon_concept_references ON (((h.id = taxon_concept_references.taxon_concept_id) AND ((taxon_concept_references.data -> 'usr_is_std_ref'::text) = 't'::text)))) WHERE (h.parent_id IS NULL) GROUP BY h.id UNION ALL SELECT hi.*::taxon_concepts AS hi, hi.id, CASE WHEN (((hi.data -> 'usr_no_std_ref'::text))::boolean = true) THEN ARRAY[]::integer[] ELSE (q.standard_references_ids_ary || taxon_concept_references.reference_id) END AS "case" FROM ((q JOIN taxon_concepts hi ON ((hi.parent_id = (q.h).id))) LEFT JOIN taxon_concept_references ON (((hi.id = taxon_concept_references.taxon_concept_id) AND ((taxon_concept_references.data -> 'usr_is_std_ref'::text) = 't'::text))))) SELECT DISTINCT q.id, unnest(q.standard_references_ids_ary) AS std_ref_id FROM q) SELECT taxa_with_std_refs.id AS taxon_concept_id_sr, array_agg(taxa_with_std_refs.std_ref_id) AS standard_references_ids_ary FROM taxa_with_std_refs WHERE (taxa_with_std_refs.std_ref_id IS NOT NULL) GROUP BY taxa_with_std_refs.id) standard_references_ids ON ((taxon_concepts.id = standard_references_ids.taxon_concept_id_sr)));
ALTER VIEW taxon_concepts_view SET ();


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