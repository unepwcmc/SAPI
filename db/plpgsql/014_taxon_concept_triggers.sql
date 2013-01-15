CREATE OR REPLACE FUNCTION trg_taxonomic_positions() RETURNS trigger AS $trg_taxonomic_positions$
  BEGIN
    IF TG_OP = 'INSERT' AND NEW.parent_id IS NOT NULL THEN
      PERFORM rebuild_taxonomic_positions_from_root(NEW.parent_id);
    ELSE
      PERFORM rebuild_taxonomic_positions_from_root(NEW.id);
    END IF;
    RETURN NEW;
  END;
$trg_taxonomic_positions$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_taxonomic_positions ON taxon_concepts;

CREATE TRIGGER trg_taxonomic_positions
  AFTER INSERT OR UPDATE OF taxonomic_position
  ON taxon_concepts
  FOR EACH ROW
  WHEN (pg_trigger_depth() = 0)
    EXECUTE PROCEDURE trg_taxonomic_positions();

CREATE OR REPLACE FUNCTION trg_names_and_ranks() RETURNS trigger AS $trg_names_and_ranks$
  BEGIN
    PERFORM rebuild_names_and_ranks_for_node(NEW.id);
    RETURN NEW;
  END;
$trg_names_and_ranks$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_names_and_ranks ON taxon_concepts;

CREATE TRIGGER trg_names_and_ranks
  AFTER INSERT OR UPDATE OF taxon_name_id, rank_id
  ON taxon_concepts
  FOR EACH ROW
    EXECUTE PROCEDURE trg_names_and_ranks();