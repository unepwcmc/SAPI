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
    name character varying(255),
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
    name character varying(255),
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
    lft integer,
    rgt integer,
    parent_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    effective_at timestamp without time zone DEFAULT '2012-09-21 07:32:20'::timestamp without time zone NOT NULL,
    annotation_id integer,
    is_current boolean DEFAULT false NOT NULL
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
    designation_id integer,
    name character varying(255),
    abbreviation character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: listing_changes_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW listing_changes_view AS
    WITH multilingual_annotations AS (SELECT ct.annotation_id_mul, ct.english_note[1] AS english_full_note, ct.english_note[2] AS english_short_note, ct.spanish_note[1] AS spanish_full_note, ct.spanish_note[2] AS spanish_short_note, ct.french_note[1] AS french_full_note, ct.french_note[2] AS french_short_note FROM crosstab('SELECT annotations.id AS annotation_id_mul,
        SUBSTRING(languages.name FROM 1 FOR 1) AS lng,
        ARRAY[annotation_translations.full_note, annotation_translations.short_note]
        FROM "annotations"
        INNER JOIN "annotation_translations"
          ON "annotation_translations"."annotation_id" = "annotations"."id" 
        INNER JOIN "languages"
          ON "languages"."id" = "annotation_translations"."language_id"
        ORDER BY 1,2'::text) ct(annotation_id_mul integer, english_note text[], spanish_note text[], french_note text[])) SELECT listing_changes.id, listing_changes.taxon_concept_id, listing_changes.effective_at, listing_changes.species_listing_id, species_listings.abbreviation AS species_listing_name, listing_changes.change_type_id, change_types.name AS change_type_name, listing_distributions.geo_entity_id AS party_id, geo_entities.iso_code2 AS party_name, generic_annotations.symbol, generic_annotations.parent_symbol, multilingual_generic_annotations.english_full_note AS generic_english_full_note, multilingual_generic_annotations.spanish_full_note AS generic_spanish_full_note, multilingual_generic_annotations.french_full_note AS generic_french_full_note, multilingual_specific_annotations.english_full_note, multilingual_specific_annotations.spanish_full_note, multilingual_specific_annotations.french_full_note, multilingual_specific_annotations.english_short_note, multilingual_specific_annotations.spanish_short_note, multilingual_specific_annotations.french_short_note, listing_changes.is_current FROM ((((((((listing_changes LEFT JOIN change_types ON ((listing_changes.change_type_id = change_types.id))) LEFT JOIN species_listings ON ((listing_changes.species_listing_id = species_listings.id))) LEFT JOIN listing_distributions ON (((listing_changes.id = listing_distributions.listing_change_id) AND (listing_distributions.is_party = true)))) LEFT JOIN geo_entities ON ((geo_entities.id = listing_distributions.geo_entity_id))) LEFT JOIN annotations specific_annotations ON ((specific_annotations.listing_change_id = listing_changes.id))) LEFT JOIN annotations generic_annotations ON ((generic_annotations.id = listing_changes.annotation_id))) LEFT JOIN multilingual_annotations multilingual_specific_annotations ON ((specific_annotations.id = multilingual_specific_annotations.annotation_id_mul))) LEFT JOIN multilingual_annotations multilingual_generic_annotations ON ((generic_annotations.id = multilingual_generic_annotations.annotation_id_mul))) ORDER BY listing_changes.taxon_concept_id, listing_changes.effective_at, CASE WHEN ((change_types.name)::text = 'ADDITION'::text) THEN 0 WHEN ((change_types.name)::text = 'RESERVATION'::text) THEN 1 WHEN ((change_types.name)::text = 'RESERVATION_WITHDRAWAL'::text) THEN 2 WHEN ((change_types.name)::text = 'DELETION'::text) THEN 3 ELSE NULL::integer END;


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
    lft integer,
    rgt integer,
    rank_id integer NOT NULL,
    designation_id integer NOT NULL,
    taxon_name_id integer NOT NULL,
    legacy_id integer,
    legacy_type character varying(255),
    data hstore,
    fully_covered boolean DEFAULT true NOT NULL,
    listing hstore,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    fully_covered boolean,
    designation_is_cites boolean,
    full_name text,
    rank_name text,
    cites_accepted boolean,
    kingdom_position integer,
    taxonomic_position text,
    kingdom_name text,
    phylum_name text,
    class_name text,
    order_name text,
    family_name text,
    genus_name text,
    species_name text,
    subspecies_name text,
    kingdom_id text,
    phylum_id text,
    class_id text,
    order_id text,
    family_id text,
    genus_id text,
    species_id text,
    subspecies_id text,
    cites_listed boolean,
    cites_show boolean,
    cites_i text,
    cites_ii text,
    cites_iii text,
    cites_del boolean,
    current_listing text,
    usr_cites_exclusion boolean,
    cites_exclusion boolean,
    taxon_concept_id_com integer,
    english_names_ary character varying[],
    french_names_ary character varying[],
    spanish_names_ary character varying[],
    taxon_concept_id_syn integer,
    synonyms_ary text[],
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
    fully_covered boolean,
    designation_is_cites boolean,
    full_name text,
    rank_name text,
    cites_accepted boolean,
    kingdom_position integer,
    taxonomic_position text,
    kingdom_name text,
    phylum_name text,
    class_name text,
    order_name text,
    family_name text,
    genus_name text,
    species_name text,
    subspecies_name text,
    kingdom_id text,
    phylum_id text,
    class_id text,
    order_id text,
    family_id text,
    genus_id text,
    species_id text,
    subspecies_id text,
    cites_listed boolean,
    cites_show boolean,
    cites_i text,
    cites_ii text,
    cites_iii text,
    cites_del boolean,
    current_listing text,
    usr_cites_exclusion boolean,
    cites_exclusion boolean,
    taxon_concept_id_com integer,
    english_names_ary character varying[],
    french_names_ary character varying[],
    spanish_names_ary character varying[],
    taxon_concept_id_syn integer,
    synonyms_ary text[],
    countries_ids_ary integer[],
    standard_references_ids_ary integer[]
);


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
-- Name: index_listing_changes_on_annotation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_changes_on_annotation_id ON listing_changes USING btree (annotation_id);


--
-- Name: index_listing_distributions_on_geo_entity_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_listing_distributions_on_geo_entity_id ON listing_distributions USING btree (geo_entity_id);


--
-- Name: index_taxon_concepts_on_lft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taxon_concepts_on_lft ON taxon_concepts USING btree (lft);


--
-- Name: listing_changes_mview_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX listing_changes_mview_on_id ON listing_changes_mview USING btree (id);


--
-- Name: taxon_concepts_mview_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX taxon_concepts_mview_on_id ON taxon_concepts_mview USING btree (id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS ON SELECT TO taxon_concepts_view DO INSTEAD SELECT taxon_concepts.id, taxon_concepts.fully_covered, CASE WHEN ((designations.name)::text = 'CITES'::text) THEN true ELSE false END AS designation_is_cites, (taxon_concepts.data -> 'full_name'::text) AS full_name, (taxon_concepts.data -> 'rank_name'::text) AS rank_name, ((taxon_concepts.data -> 'cites_accepted'::text))::boolean AS cites_accepted, CASE WHEN ((taxon_concepts.data -> 'kingdom_name'::text) = 'Animalia'::text) THEN 0 ELSE 1 END AS kingdom_position, (taxon_concepts.data -> 'taxonomic_position'::text) AS taxonomic_position, (taxon_concepts.data -> 'kingdom_name'::text) AS kingdom_name, (taxon_concepts.data -> 'phylum_name'::text) AS phylum_name, (taxon_concepts.data -> 'class_name'::text) AS class_name, (taxon_concepts.data -> 'order_name'::text) AS order_name, (taxon_concepts.data -> 'family_name'::text) AS family_name, (taxon_concepts.data -> 'genus_name'::text) AS genus_name, (taxon_concepts.data -> 'species_name'::text) AS species_name, (taxon_concepts.data -> 'subspecies_name'::text) AS subspecies_name, (taxon_concepts.data -> 'kingdom_id'::text) AS kingdom_id, (taxon_concepts.data -> 'phylum_id'::text) AS phylum_id, (taxon_concepts.data -> 'class_id'::text) AS class_id, (taxon_concepts.data -> 'order_id'::text) AS order_id, (taxon_concepts.data -> 'family_id'::text) AS family_id, (taxon_concepts.data -> 'genus_id'::text) AS genus_id, (taxon_concepts.data -> 'species_id'::text) AS species_id, (taxon_concepts.data -> 'subspecies_id'::text) AS subspecies_id, ((taxon_concepts.listing -> 'cites_listed'::text))::boolean AS cites_listed, ((taxon_concepts.listing -> 'cites_show'::text))::boolean AS cites_show, CASE WHEN ((taxon_concepts.listing -> 'cites_I'::text) = 'I'::text) THEN 't'::text ELSE 'f'::text END AS cites_i, CASE WHEN ((taxon_concepts.listing -> 'cites_II'::text) = 'II'::text) THEN 't'::text ELSE 'f'::text END AS cites_ii, CASE WHEN ((taxon_concepts.listing -> 'cites_III'::text) = 'III'::text) THEN 't'::text ELSE 'f'::text END AS cites_iii, ((taxon_concepts.listing -> 'cites_del'::text))::boolean AS cites_del, (taxon_concepts.listing -> 'cites_listing'::text) AS current_listing, ((taxon_concepts.listing -> 'usr_cites_exclusion'::text))::boolean AS usr_cites_exclusion, ((taxon_concepts.listing -> 'cites_exclusion'::text))::boolean AS cites_exclusion, common_names.taxon_concept_id_com, common_names.english_names_ary, common_names.french_names_ary, common_names.spanish_names_ary, synonyms.taxon_concept_id_syn, synonyms.synonyms_ary, countries_ids.countries_ids_ary, standard_references_ids.standard_references_ids_ary FROM (((((taxon_concepts LEFT JOIN designations ON ((designations.id = taxon_concepts.designation_id))) LEFT JOIN (SELECT ct.taxon_concept_id_com, ct.english_names_ary, ct.french_names_ary, ct.spanish_names_ary FROM crosstab('SELECT taxon_concepts.id AS taxon_concept_id_com,
        SUBSTRING(languages.name FROM 1 FOR 1) AS lng,
        ARRAY_AGG(common_names.name ORDER BY common_names.id) AS common_names_ary 
        FROM "taxon_concepts"
        INNER JOIN "taxon_commons"
          ON "taxon_commons"."taxon_concept_id" = "taxon_concepts"."id" 
        INNER JOIN "common_names"
          ON "common_names"."id" = "taxon_commons"."common_name_id" 
        INNER JOIN "languages"
          ON "languages"."id" = "common_names"."language_id"
        GROUP BY taxon_concepts.id, SUBSTRING(languages.name FROM 1 FOR 1)
        ORDER BY 1,2'::text) ct(taxon_concept_id_com integer, english_names_ary character varying[], french_names_ary character varying[], spanish_names_ary character varying[])) common_names ON ((taxon_concepts.id = common_names.taxon_concept_id_com))) LEFT JOIN (SELECT taxon_concepts.id AS taxon_concept_id_syn, array_agg((synonym_tc.data -> 'full_name'::text)) AS synonyms_ary FROM (((taxon_concepts LEFT JOIN taxon_relationships ON ((taxon_relationships.taxon_concept_id = taxon_concepts.id))) LEFT JOIN taxon_relationship_types ON ((taxon_relationship_types.id = taxon_relationships.taxon_relationship_type_id))) LEFT JOIN taxon_concepts synonym_tc ON ((synonym_tc.id = taxon_relationships.other_taxon_concept_id))) GROUP BY taxon_concepts.id) synonyms ON ((taxon_concepts.id = synonyms.taxon_concept_id_syn))) LEFT JOIN (SELECT taxon_concepts.id AS taxon_concept_id_cnt, array_agg(geo_entities.id ORDER BY geo_entities.name) AS countries_ids_ary FROM (((taxon_concepts LEFT JOIN taxon_concept_geo_entities ON ((taxon_concept_geo_entities.taxon_concept_id = taxon_concepts.id))) LEFT JOIN geo_entities ON ((taxon_concept_geo_entities.geo_entity_id = geo_entities.id))) LEFT JOIN geo_entity_types ON (((geo_entity_types.id = geo_entities.geo_entity_type_id) AND ((geo_entity_types.name)::text = 'COUNTRY'::text)))) GROUP BY taxon_concepts.id) countries_ids ON ((taxon_concepts.id = countries_ids.taxon_concept_id_cnt))) LEFT JOIN (WITH RECURSIVE q AS (SELECT h.*::taxon_concepts AS h, h.id, array_agg(taxon_concept_references.reference_id) AS standard_references_ids_ary FROM (taxon_concepts h LEFT JOIN taxon_concept_references ON (((h.id = taxon_concept_references.taxon_concept_id) AND ((taxon_concept_references.data -> 'usr_is_std_ref'::text) = 't'::text)))) WHERE (h.parent_id IS NULL) GROUP BY h.id UNION ALL SELECT hi.*::taxon_concepts AS hi, hi.id, CASE WHEN (((hi.data -> 'usr_no_std_ref'::text))::boolean = true) THEN ARRAY[]::integer[] ELSE (q.standard_references_ids_ary || taxon_concept_references.reference_id) END AS "case" FROM ((q JOIN taxon_concepts hi ON ((hi.parent_id = (q.h).id))) LEFT JOIN taxon_concept_references ON (((hi.id = taxon_concept_references.taxon_concept_id) AND ((taxon_concept_references.data -> 'usr_is_std_ref'::text) = 't'::text))))) SELECT q.id AS taxon_concept_id_sr, ARRAY(SELECT DISTINCT s.s FROM unnest(q.standard_references_ids_ary) s(s) WHERE (s.s IS NOT NULL)) AS standard_references_ids_ary FROM q) standard_references_ids ON ((taxon_concepts.id = standard_references_ids.taxon_concept_id_sr)));
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

INSERT INTO schema_migrations (version) VALUES ('20120530135534');

INSERT INTO schema_migrations (version) VALUES ('20120703141230');

INSERT INTO schema_migrations (version) VALUES ('20121004124447');

INSERT INTO schema_migrations (version) VALUES ('20121009113034');

INSERT INTO schema_migrations (version) VALUES ('20121009113846');

INSERT INTO schema_migrations (version) VALUES ('20121009121137');

INSERT INTO schema_migrations (version) VALUES ('20121009121456');