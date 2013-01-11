--
-- Name: rebuild_names_and_ranks_from_root(root_id integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_names_and_ranks_from_root(root_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    RAISE NOTICE 'rebuild names and ranks from %', root_id;
    WITH RECURSIVE q AS (
      SELECT h.id, ranks.name as rank_name,
      hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
      hstore(LOWER(ranks.name) || '_id', (h.id)::VARCHAR) AS ancestors
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = root_id

      UNION ALL

      SELECT hi.id, ranks.name,
      ancestors ||
      hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
      hstore(LOWER(ranks.name) || '_id', (hi.id)::VARCHAR)
      FROM q
      JOIN taxon_concepts hi
      ON hi.parent_id = q.id
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET
    full_name = 
      CASE
        WHEN rank_name = 'SPECIES' THEN
          -- now create a binomen for full name
          CAST(ancestors -> 'genus_name' AS VARCHAR) || ' ' ||
          LOWER(CAST(ancestors -> 'species_name' AS VARCHAR))
        WHEN rank_name = 'SUBSPECIES' THEN
          -- now create a trinomen for full name
          CAST(ancestors -> 'genus_name' AS VARCHAR) || ' ' ||
          LOWER(CAST(ancestors -> 'species_name' AS VARCHAR)) || ' ' ||
          LOWER(CAST(ancestors -> 'subspecies_name' AS VARCHAR))
        ELSE ancestors -> LOWER(rank_name || '_name')
      END,
    data = data || ancestors || hstore('rank_name', rank_name)
    FROM q
    WHERE taxon_concepts.id = q.id;

  END;
  $$;

COMMENT ON FUNCTION rebuild_names_and_ranks() IS 'Procedure to rebuild the computed full name, rank and ancestor names fields in taxon_concepts.';

--
-- Name: rebuild_names_and_ranks(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_names_and_ranks() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    root_id integer;
  BEGIN
    FOR root_id IN SELECT id FROM taxon_concepts
    WHERE parent_id IS NULL
    LOOP
      PERFORM rebuild_names_and_ranks_from_root(root_id);
    END LOOP;

  END;
  $$;

COMMENT ON FUNCTION rebuild_names_and_ranks() IS 'Procedure to rebuild the computed full name, rank and ancestor names fields in taxon_concepts.';
