CREATE OR REPLACE FUNCTION taxon_concepts_refresh_row(row_id INTEGER) RETURNS VOID
SECURITY DEFINER
LANGUAGE 'plpgsql' AS $$
BEGIN
  RAISE NOTICE 'refreshing';
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
