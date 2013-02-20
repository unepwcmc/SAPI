CREATE OR REPLACE FUNCTION taxon_concepts_refresh_row(row_id INTEGER) RETURNS VOID
SECURITY DEFINER
LANGUAGE 'plpgsql' AS $$
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

DROP FUNCTION IF EXISTS taxon_concepts_invalidate_row(id INTEGER);
CREATE OR REPLACE FUNCTION taxon_concepts_invalidate_row(row_id INTEGER) RETURNS VOID
SECURITY DEFINER
LANGUAGE 'plpgsql' AS $$
BEGIN
  UPDATE taxon_concepts_mview tc
  SET dirty = TRUE
  WHERE tc.id = row_id;
  RETURN;
END
$$;

CREATE OR REPLACE FUNCTION listing_changes_refresh_row(row_id INTEGER) RETURNS VOID
SECURITY DEFINER
LANGUAGE 'plpgsql' AS $$
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

DROP FUNCTION IF EXISTS listing_changes_invalidate_row(id INTEGER);
CREATE OR REPLACE FUNCTION listing_changes_invalidate_row(row_id INTEGER) RETURNS VOID
SECURITY DEFINER
LANGUAGE 'plpgsql' AS $$
BEGIN
  UPDATE listing_changes_mview lc
  SET dirty = TRUE
  WHERE lc.id = row_id;
  RETURN;
END
$$;
