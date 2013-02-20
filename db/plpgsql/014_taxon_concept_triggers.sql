CREATE OR REPLACE FUNCTION trg_taxon_concepts_u() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
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

CREATE OR REPLACE FUNCTION trg_taxon_concepts_d() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(OLD.id);
  RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION trg_taxon_concepts_i() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
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

DROP TRIGGER IF EXISTS trg_taxon_concepts_u ON taxon_concepts;
CREATE TRIGGER trg_taxon_concepts_u AFTER UPDATE ON taxon_concepts
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concepts_u();
DROP TRIGGER IF EXISTS trg_taxon_concepts_d ON taxon_concepts;
CREATE TRIGGER trg_taxon_concepts_d AFTER DELETE ON taxon_concepts
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concepts_d();
DROP TRIGGER IF EXISTS trg_taxon_concepts_i ON taxon_concepts;
CREATE TRIGGER trg_taxon_concepts_i AFTER INSERT ON taxon_concepts
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concepts_i();

-- RANKS

CREATE OR REPLACE FUNCTION trg_ranks_u() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
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

DROP TRIGGER IF EXISTS trg_ranks_u ON ranks;
CREATE TRIGGER trg_ranks_u AFTER UPDATE ON ranks
FOR EACH ROW EXECUTE PROCEDURE trg_ranks_u();

-- TAXON_NAMES

CREATE OR REPLACE FUNCTION trg_taxon_names_u() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  IF OLD.name <> NEW.name THEN
    PERFORM taxon_concepts_refresh_row(tc.id)
    FROM taxon_concepts tc
    WHERE tc.taxon_name_id = NEW.id;
  END IF;
  RETURN NULL;
END
$$;

DROP TRIGGER IF EXISTS trg_taxon_names_u ON taxon_names;
CREATE TRIGGER trg_taxon_names_u AFTER UPDATE ON taxon_names
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_names_u();

-- COMMON_NAMES

CREATE OR REPLACE FUNCTION trg_common_names_u() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
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

DROP TRIGGER IF EXISTS trg_common_names_u ON common_names;
CREATE TRIGGER trg_common_names_u AFTER UPDATE ON common_names
FOR EACH ROW EXECUTE PROCEDURE trg_common_names_u();

-- TAXON_COMMONS

CREATE OR REPLACE FUNCTION trg_taxon_commons_ui() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = NEW.taxon_concept_id;
  RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION trg_taxon_commons_d() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = OLD.taxon_concept_id;
  RETURN NULL;
END
$$;

DROP TRIGGER IF EXISTS trg_taxon_commons_ui ON taxon_commons;
CREATE TRIGGER trg_taxon_commons_ui AFTER INSERT OR UPDATE ON taxon_commons
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_commons_ui();
DROP TRIGGER IF EXISTS trg_taxon_commons_d ON taxon_commons;
CREATE TRIGGER trg_taxon_commons_d AFTER DELETE ON taxon_commons
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_commons_d();

-- TAXON_RELATIONSHIPS

CREATE OR REPLACE FUNCTION trg_taxon_relationships_ui() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
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

CREATE OR REPLACE FUNCTION trg_taxon_relationships_d() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
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

DROP TRIGGER IF EXISTS trg_taxon_relationships_ui ON taxon_relationships;
CREATE TRIGGER trg_taxon_relationships_ui AFTER INSERT OR UPDATE ON taxon_relationships
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_relationships_ui();
DROP TRIGGER IF EXISTS trg_taxon_relationships_d ON taxon_relationships;
CREATE TRIGGER trg_taxon_relationships_d AFTER DELETE ON taxon_relationships
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_relationships_d();

-- GEO_ENTITIES

CREATE OR REPLACE FUNCTION trg_geo_entities_u() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
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

DROP TRIGGER IF EXISTS trg_geo_entities_u ON geo_entities;
CREATE TRIGGER trg_geo_entities_u AFTER UPDATE ON geo_entities
FOR EACH ROW EXECUTE PROCEDURE trg_geo_entities_u();

-- DISTRIBUTIONS

CREATE OR REPLACE FUNCTION trg_distributions_ui() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = NEW.taxon_concept_id;
  RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION trg_distributions_d() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = OLD.taxon_concept_id;
  RETURN NULL;
END
$$;

DROP TRIGGER IF EXISTS trg_distributions_ui ON distributions;
CREATE TRIGGER trg_distributions_ui AFTER INSERT OR UPDATE ON distributions
FOR EACH ROW EXECUTE PROCEDURE trg_distributions_ui();
DROP TRIGGER IF EXISTS trg_distributions_d ON distributions;
CREATE TRIGGER trg_distributions_d AFTER DELETE ON distributions
FOR EACH ROW EXECUTE PROCEDURE trg_distributions_d();

-- TAXON_CONCEPT_REFERENCES -- TODO references cascade

CREATE OR REPLACE FUNCTION trg_taxon_concept_references_ui() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = NEW.taxon_concept_id;
  RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION trg_taxon_concept_references_d() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM taxon_concepts_refresh_row(tc.id)
  FROM taxon_concepts tc
  WHERE tc.id = OLD.taxon_concept_id;
  RETURN NULL;
END
$$;

DROP TRIGGER IF EXISTS trg_taxon_concept_references_ui ON taxon_concept_references;
CREATE TRIGGER trg_taxon_concept_references_ui AFTER INSERT OR UPDATE ON taxon_concept_references
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concept_references_ui();
DROP TRIGGER IF EXISTS trg_taxon_concept_references_d ON taxon_concept_references;
CREATE TRIGGER trg_taxon_concept_references_d AFTER DELETE ON taxon_concept_references
FOR EACH ROW EXECUTE PROCEDURE trg_taxon_concept_references_d();

DROP TRIGGER IF EXISTS trg_taxonomic_positions ON taxon_concepts;
DROP FUNCTION IF EXISTS trg_taxonomic_positions();
DROP TRIGGER IF EXISTS trg_names_and_ranks ON taxon_concepts;
DROP FUNCTION IF EXISTS trg_names_and_ranks();
