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
  IF OLD.taxon_name_id <> NEW.taxon_name_id OR OLD.rank_id <> NEW.rank_id THEN
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

DROP TRIGGER IF EXISTS trg_taxonomic_positions ON taxon_concepts;
DROP FUNCTION IF EXISTS trg_taxonomic_positions();
DROP TRIGGER IF EXISTS trg_names_and_ranks ON taxon_concepts;
DROP FUNCTION IF EXISTS trg_names_and_ranks();
