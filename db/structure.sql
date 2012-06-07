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


SET search_path = public, pg_catalog;

--
-- Name: taxon_concept_with_ancestors; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE taxon_concept_with_ancestors AS (
	id integer,
	names character varying(255)[],
	ranks character varying(255)[]
);


--
-- Name: taxon_concept_with_ancestors(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION taxon_concept_with_ancestors(param_id integer) RETURNS taxon_concept_with_ancestors
    LANGUAGE plpgsql
    AS $$
  DECLARE
    tmp_rec taxon_concept_with_ancestors;
  BEGIN
      -- this recursive statement will go through the forest from the roots up
      -- and concatenate ancestor names and ranks in hierarchic order
      WITH RECURSIVE q AS
      (
      SELECT  h,
      ARRAY[taxon_names.scientific_name] AS names_ary,
      ARRAY[ranks.name] AS ranks_ary
      FROM    taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.parent_id IS NULL
      UNION ALL
      SELECT  hi,
      CAST(names_ary || taxon_names.scientific_name as character varying(255)[]),
      CAST(ranks_ary || ranks.name as character varying(255)[])
      FROM    q
      JOIN    taxon_concepts hi
      ON      hi.parent_id = (q.h).id
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
      )
      SELECT
      (q.h).id,
      names_ary::VARCHAR AS names,
      ranks_ary::VARCHAR AS ranks
      INTO tmp_rec
      FROM    q
      WHERE (q.h).id = param_id;
    return tmp_rec;
  END;
$$;


--
-- Name: FUNCTION taxon_concept_with_ancestors(param_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION taxon_concept_with_ancestors(param_id integer) IS 'Returns ordered ancestor names and ranks for given taxon concept id';


--
-- Name: update_taxon_concept_hstore_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_taxon_concept_hstore_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    res hstore;
    taxon_data_rec taxon_concept_with_ancestors;
    upper INTEGER;
    rank_name CHARACTER VARYING(255);
    scientific_name CHARACTER VARYING(255);
    full_name CHARACTER VARYING(255);
  BEGIN
    res := ''::hstore;
    SELECT * FROM taxon_concept_with_ancestors(NEW.id) INTO taxon_data_rec;
    IF FOUND THEN
      upper = array_upper(taxon_data_rec.ranks, 1);
      IF upper IS NOT NULL THEN
        rank_name := taxon_data_rec.ranks[upper];
        if rank_name = 'PHYLUM' then
          raise notice 'phylum %', NEW.id;
        end if;
        scientific_name := taxon_data_rec.names[upper];
        -- for each ancestor create a field in the hstore
        FOR i IN array_lower(taxon_data_rec.ranks, 1)..upper
        LOOP
          res := res || (LOWER(taxon_data_rec.ranks[i]) || '_name' => taxon_data_rec.names[i]);
        END LOOP;
        if rank_name = 'PHYLUM' then
          raise notice '%',res;
        end if;
        -- construct the full name for display purposes
        IF rank_name = 'SPECIES' THEN
          -- now create a binomen for full name
          full_name := CAST(res -> 'genus_name' AS character varying(255)) || ' ' ||
          LOWER(scientific_name);
        ELSIF rank_name = 'SUBSPECIES' THEN
          -- now create a trinomen for full name
          full_name := CAST(res -> 'genus_name' AS character varying(255)) || ' ' ||
          LOWER(CAST(res -> 'species_name' AS character varying(255))) || ' ' ||
          scientific_name;
        ELSE
           full_name := scientific_name;
        END IF;
        if rank_name = 'PHYLUM' then
          raise notice '%',full_name;
        end if;
        res := res || 
        ('scientific_name' => scientific_name) ||
        ('full_name' => full_name) ||
        ('rank_name' => rank_name);
        if rank_name = 'PHYLUM' then
          raise notice '%',res;
        end if;
      END IF;
      UPDATE taxon_concepts SET data = res WHERE id = NEW.id;
    END IF;
    RETURN NULL;
  END;
$$;


--
-- Name: FUNCTION update_taxon_concept_hstore_trigger(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION update_taxon_concept_hstore_trigger() IS 'Trigger function that updates additional fields in the hstore column';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: authors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authors (
    id integer NOT NULL,
    first_name character varying(255),
    middle_name character varying(255),
    last_name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authors_id_seq OWNED BY authors.id;


--
-- Name: change_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE change_types (
    id integer NOT NULL,
    name character varying(255),
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
-- Name: cites_regions_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cites_regions_import (
    name character varying
);


--
-- Name: countries_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries_import (
    legacy_id integer,
    iso2 character varying,
    iso3 character varying,
    name character varying,
    long_name character varying,
    region_number character varying
);


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
-- Name: distribution_import; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE distribution_import (
    species_id integer,
    country_id integer,
    country_name character varying
);


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
-- Name: reference_authors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reference_authors (
    id integer NOT NULL,
    reference_id integer NOT NULL,
    author_id integer NOT NULL,
    index integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reference_authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reference_authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reference_authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reference_authors_id_seq OWNED BY reference_authors.id;


--
-- Name: references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "references" (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    year character varying(255),
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
    kingdom character varying,
    phylum character varying,
    class character varying,
    taxonorder character varying,
    family character varying,
    genus character varying,
    species character varying,
    spcinfra character varying,
    spcrecid integer,
    spcstatus character varying
);


--
-- Name: species_listings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE species_listings (
    id integer NOT NULL,
    designation_id integer,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
    spcrecid integer,
    depth integer,
    designation_id integer NOT NULL,
    taxon_name_id integer NOT NULL,
    legacy_id integer,
    inherit_distribution boolean DEFAULT true NOT NULL,
    inherit_legislation boolean DEFAULT true NOT NULL,
    inherit_references boolean DEFAULT true NOT NULL,
    data hstore DEFAULT ''::hstore
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
-- Name: taxon_distributions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_distributions (
    id integer NOT NULL,
    taxon_id integer NOT NULL,
    distribution_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_distributions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_distributions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_distributions_id_seq OWNED BY taxon_distributions.id;


--
-- Name: taxon_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_names (
    id integer NOT NULL,
    scientific_name character varying(255) NOT NULL,
    basionym_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    abbreviation character varying(64)
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
-- Name: taxon_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_references (
    id integer NOT NULL,
    referenceable_id integer,
    referenceable_type character varying(255) DEFAULT 'Taxon'::character varying NOT NULL,
    reference_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxon_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxon_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_references_id_seq OWNED BY taxon_references.id;


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

ALTER TABLE ONLY authors ALTER COLUMN id SET DEFAULT nextval('authors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY change_types ALTER COLUMN id SET DEFAULT nextval('change_types_id_seq'::regclass);


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

ALTER TABLE ONLY listing_changes ALTER COLUMN id SET DEFAULT nextval('listing_changes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ranks ALTER COLUMN id SET DEFAULT nextval('ranks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reference_authors ALTER COLUMN id SET DEFAULT nextval('reference_authors_id_seq'::regclass);


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

ALTER TABLE ONLY taxon_concept_geo_entities ALTER COLUMN id SET DEFAULT nextval('taxon_concept_geo_entities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_concepts ALTER COLUMN id SET DEFAULT nextval('taxon_concepts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_distributions ALTER COLUMN id SET DEFAULT nextval('taxon_distributions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_names ALTER COLUMN id SET DEFAULT nextval('taxon_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_references ALTER COLUMN id SET DEFAULT nextval('taxon_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationship_types ALTER COLUMN id SET DEFAULT nextval('taxon_relationship_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taxon_relationships ALTER COLUMN id SET DEFAULT nextval('taxon_relationships_id_seq'::regclass);


--
-- Name: authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: change_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY change_types
    ADD CONSTRAINT change_types_pkey PRIMARY KEY (id);


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
-- Name: listing_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listing_changes
    ADD CONSTRAINT listing_changes_pkey PRIMARY KEY (id);


--
-- Name: ranks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ranks
    ADD CONSTRAINT ranks_pkey PRIMARY KEY (id);


--
-- Name: reference_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reference_authors
    ADD CONSTRAINT reference_authors_pkey PRIMARY KEY (id);


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
-- Name: taxon_concept_geo_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_concept_geo_entities
    ADD CONSTRAINT taxon_concept_geo_entities_pkey PRIMARY KEY (id);


--
-- Name: taxon_concepts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_concepts
    ADD CONSTRAINT taxon_concepts_pkey PRIMARY KEY (id);


--
-- Name: taxon_distributions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_distributions
    ADD CONSTRAINT taxon_distributions_pkey PRIMARY KEY (id);


--
-- Name: taxon_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_names
    ADD CONSTRAINT taxon_names_pkey PRIMARY KEY (id);


--
-- Name: taxon_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_references
    ADD CONSTRAINT taxon_references_pkey PRIMARY KEY (id);


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
-- Name: taxon_concept_insert_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER taxon_concept_insert_trigger AFTER INSERT ON taxon_concepts FOR EACH ROW EXECUTE PROCEDURE update_taxon_concept_hstore_trigger();


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

INSERT INTO schema_migrations (version) VALUES ('20120530135535');

INSERT INTO schema_migrations (version) VALUES ('20120530135832');

INSERT INTO schema_migrations (version) VALUES ('20120531091826');

INSERT INTO schema_migrations (version) VALUES ('20120606074358');

INSERT INTO schema_migrations (version) VALUES ('20120606125349');

INSERT INTO schema_migrations (version) VALUES ('20120606131036');

INSERT INTO schema_migrations (version) VALUES ('20120606132104');

INSERT INTO schema_migrations (version) VALUES ('20120607073043');