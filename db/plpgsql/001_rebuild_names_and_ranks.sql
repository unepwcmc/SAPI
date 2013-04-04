CREATE OR REPLACE FUNCTION spp(rank_name VARCHAR(255)) RETURNS BOOLEAN
  LANGUAGE plpgsql IMMUTABLE
  AS $$
  BEGIN
    RETURN CASE
      WHEN rank_name IN ('GENUS', 'FAMILY', 'SUBFAMILY', 'ORDER') THEN TRUE
      ELSE FALSE
    END;
  END;
  $$;

CREATE OR REPLACE FUNCTION full_name(rank_name VARCHAR(255), ancestors HSTORE) RETURNS VARCHAR(255)
  LANGUAGE plpgsql IMMUTABLE
  AS $$
  BEGIN
    RETURN CASE
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
    END;
  END;
  $$;

CREATE OR REPLACE FUNCTION ancestors_data(node_id INTEGER) RETURNS HSTORE
  LANGUAGE plpgsql
  AS $$
  DECLARE
    result HSTORE;
    ancestor_row RECORD;
  BEGIN
    result := ''::HSTORE;
    FOR ancestor_row IN 
      WITH RECURSIVE q AS (
        SELECT h.id, h.parent_id, ranks.name AS rank_name, taxon_names.scientific_name AS scientific_name
        FROM taxon_concepts h
        INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
        INNER JOIN ranks ON h.rank_id = ranks.id
        WHERE h.id = node_id

        UNION

        SELECT hi.id, hi.parent_id, ranks.name, taxon_names.scientific_name

        FROM q
        JOIN taxon_concepts hi
        ON hi.id = q.parent_id
        INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
        INNER JOIN ranks ON hi.rank_id = ranks.id
      )
      SELECT 
      id, rank_name, scientific_name
      FROM q
    LOOP
      result := result ||
        HSTORE(LOWER(ancestor_row.rank_name) || '_name', ancestor_row.scientific_name) ||
        HSTORE(LOWER(ancestor_row.rank_name) || '_id', ancestor_row.id::VARCHAR);
    END LOOP;
    RETURN result;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_names_and_ranks_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    WITH q AS (
      SELECT taxon_concepts.id, ranks.name AS rank_name, ancestors_data(node_id) AS ancestors
      FROM taxon_concepts
      INNER JOIN ranks ON taxon_concepts.rank_id = ranks.id
      WHERE taxon_concepts.id = node_id
    )
    UPDATE taxon_concepts
    SET full_name = full_name(rank_name, ancestors),
      data = CASE WHEN data IS NULL THEN ''::HSTORE ELSE data END ||
        ancestors || hstore('rank_name', rank_name) || hstore('spp', spp(rank_name)::VARCHAR)
    FROM q
    WHERE taxon_concepts.id = q.id AND taxon_concepts.name_status NOT IN ('S', 'H');
  END;
  $$;

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
    full_name = full_name(rank_name, ancestors),
    data = data || ancestors || hstore('rank_name', rank_name) || hstore('spp', spp(rank_name)::VARCHAR)
    FROM q
    WHERE taxon_concepts.id = q.id;

  END;
  $$;

COMMENT ON FUNCTION rebuild_names_and_ranks_from_root(root_id integer) IS 'Procedure to rebuild the computed full name, rank and ancestor names fields in taxon_concepts.';

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
    WHERE parent_id IS NULL AND name_status = 'A'
    LOOP
      PERFORM rebuild_names_and_ranks_from_root(root_id);
    END LOOP;

  END;
  $$;

COMMENT ON FUNCTION rebuild_names_and_ranks() IS 'Procedure to rebuild the computed full name, rank and ancestor names fields in taxon_concepts.';
