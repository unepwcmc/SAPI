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
    EXECUTE PROCEDURE trg_taxonomic_positions()