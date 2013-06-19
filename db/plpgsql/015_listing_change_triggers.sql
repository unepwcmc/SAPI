CREATE OR REPLACE FUNCTION trg_listing_changes_u() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM listing_changes_refresh_row(NEW.id);
  RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION trg_listing_changes_d() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM listing_changes_refresh_row(OLD.id);
  RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION trg_listing_changes_i() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM listing_changes_refresh_row(NEW.id);
  RETURN NULL;
END
$$;

DROP TRIGGER IF EXISTS trg_listing_changes_u ON listing_changes;
CREATE TRIGGER trg_listing_changes_u AFTER UPDATE ON listing_changes
FOR EACH ROW EXECUTE PROCEDURE trg_listing_changes_u();
DROP TRIGGER IF EXISTS trg_listing_changes_d ON listing_changes;
CREATE TRIGGER trg_listing_changes_d AFTER DELETE ON listing_changes
FOR EACH ROW EXECUTE PROCEDURE trg_listing_changes_d();
DROP TRIGGER IF EXISTS trg_listing_changes_i ON listing_changes;
CREATE TRIGGER trg_listing_changes_i AFTER INSERT ON listing_changes
FOR EACH ROW EXECUTE PROCEDURE trg_listing_changes_i();

-- ANNOTATIONS

CREATE OR REPLACE FUNCTION trg_annotations_u() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM listing_changes_refresh_row(lc.id)
  FROM listing_changes lc
  WHERE lc.annotation_id = NEW.id OR lc.hash_annotation_id = NEW.id;
  RETURN NULL;
END
$$;

DROP TRIGGER IF EXISTS trg_annotations_u ON annotations;
CREATE TRIGGER trg_annotations_u AFTER UPDATE ON annotations
FOR EACH ROW EXECUTE PROCEDURE trg_annotations_u();

-- CHANGE TYPES

CREATE OR REPLACE FUNCTION trg_change_types_u() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM listing_changes_refresh_row(lc.id)
  FROM listing_changes lc
  WHERE lc.change_type_id = NEW.id;
  RETURN NULL;
END
$$;

DROP TRIGGER IF EXISTS trg_change_types_u ON change_types;
CREATE TRIGGER trg_change_types_u AFTER UPDATE OF name ON change_types
FOR EACH ROW EXECUTE PROCEDURE trg_change_types_u();

-- SPECIES LISTINGS

CREATE OR REPLACE FUNCTION trg_species_listings_u() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM listing_changes_refresh_row(lc.id)
  FROM listing_changes lc
  WHERE lc.species_listing_id = NEW.id;
  RETURN NULL;
END
$$;

DROP TRIGGER IF EXISTS trg_species_listings_u ON species_listings;
CREATE TRIGGER trg_species_listings_u AFTER UPDATE OF name ON species_listings
FOR EACH ROW EXECUTE PROCEDURE trg_species_listings_u();

-- LISTING DISTRIBUTIONS

CREATE OR REPLACE FUNCTION trg_listing_distributions_ui() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM listing_changes_refresh_row(lc.id)
  FROM listing_changes lc
  WHERE lc.id = NEW.listing_change_id;
  RETURN NULL;
END
$$;

CREATE OR REPLACE FUNCTION trg_listing_distributions_d() RETURNS TRIGGER
SECURITY DEFINER LANGUAGE 'plpgsql' AS $$
BEGIN
  PERFORM listing_changes_refresh_row(lc.id)
  FROM listing_changes lc
  WHERE lc.id = OLD.listing_change_id;
  RETURN NULL;
END
$$;

DROP TRIGGER IF EXISTS trg_listing_distributions_ui ON listing_distributions;
CREATE TRIGGER trg_listing_distributions_ui AFTER INSERT OR UPDATE ON listing_distributions
FOR EACH ROW EXECUTE PROCEDURE trg_listing_distributions_ui();
DROP TRIGGER IF EXISTS trg_listing_distributions_d ON listing_distributions;
CREATE TRIGGER trg_listing_distributions_d AFTER DELETE ON listing_distributions
FOR EACH ROW EXECUTE PROCEDURE trg_listing_distributions_d();

-- GEO ENTITIES

-- geo entities triggers are shared with taxon concepts
