CREATE OR REPLACE FUNCTION ancestor_node_ids_for_node(node_id integer) RETURNS INTEGER[]
  LANGUAGE plpgsql STABLE
  AS $$
  DECLARE
    ancestor_node_ids INTEGER[];
  BEGIN
    WITH RECURSIVE ancestors AS (
      SELECT h.id, h.parent_id
      FROM taxon_concepts h WHERE id = node_id

      UNION

      SELECT hi.id, hi.parent_id
      FROM taxon_concepts hi JOIN ancestors ON hi.id = ancestors.parent_id
    )
    SELECT ARRAY(SELECT id FROM ancestors) INTO ancestor_node_ids;
    RETURN ancestor_node_ids;
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

CREATE OR REPLACE FUNCTION ancestors_names(node_id INTEGER) RETURNS HSTORE
  LANGUAGE plpgsql
  AS $$
  DECLARE
    result HSTORE;
    ancestor_row RECORD;
  BEGIN
    WITH RECURSIVE q AS (
      SELECT h.id, h.parent_id,
        HSTORE(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
        HSTORE(LOWER(ranks.name) || '_id', h.id::VARCHAR) AS ancestors
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = node_id

      UNION

      SELECT hi.id, hi.parent_id, q.ancestors ||
        HSTORE(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
        HSTORE(LOWER(ranks.name) || '_id', hi.id::VARCHAR)
      FROM q
      JOIN taxon_concepts hi
      ON hi.id = q.parent_id
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    SELECT ancestors
    INTO result FROM q WHERE parent_id IS NULL;
    RETURN result;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_taxonomy_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    ancestor_node_id integer;
  BEGIN
    -- update full name
    WITH RECURSIVE q AS (
      SELECT h.id, ranks.name AS rank_name, ancestors_names(h.id) AS ancestors_names
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE name_status NOT IN ('H', 'S') AND
        CASE
        WHEN node_id IS NOT NULL THEN h.id = node_id
        ELSE h.parent_id IS NULL
        END

      UNION

      SELECT hi.id, ranks.name,
      ancestors_names ||
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
    full_name = full_name(rank_name, ancestors_names),
    data = CASE WHEN data IS NOT NULL THEN data ELSE ''::HSTORE END ||
      ancestors_names || hstore('rank_name', rank_name)
    FROM q
    WHERE taxon_concepts.id = q.id;

    -- find the closest ancestor with taxonomic position set
    WITH RECURSIVE self_and_ancestors AS (
        SELECT h.id, h.parent_id, h.taxonomic_position, 1 AS level
        FROM taxon_concepts h
        WHERE id = node_id

        UNION

        SELECT hi.id, hi.parent_id, hi.taxonomic_position, level + 1
        FROM taxon_concepts hi
        JOIN self_and_ancestors ON self_and_ancestors.parent_id = hi.id
    )
    SELECT id INTO ancestor_node_id
    FROM self_and_ancestors
    WHERE taxonomic_position IS NOT NULL AND id != node_id
    ORDER BY level
    LIMIT 1;

    -- update taxonomic position
    WITH RECURSIVE self_and_descendants AS (
      SELECT h.id, COALESCE(h.taxonomic_position, '') AS ancestors_taxonomic_position
      FROM taxon_concepts h
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE
        CASE
        WHEN ancestor_node_id IS NOT NULL THEN h.id = ancestor_node_id
        ELSE h.parent_id IS NULL
        END

      UNION

      SELECT hi.id,
      CASE
        WHEN (ranks.fixed_order) THEN hi.taxonomic_position
        -- use generous zero padding to accommodate for orchidacea (30 thousand species in about 900 genera)
        ELSE (self_and_descendants.ancestors_taxonomic_position || '.' || LPAD(
          (ROW_NUMBER() OVER (PARTITION BY parent_id ORDER BY full_name)::VARCHAR(64)),
          5,
          '0'
        ))::VARCHAR(255)
      END
      FROM self_and_descendants
      JOIN taxon_concepts hi ON hi.parent_id = self_and_descendants.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET
    taxonomic_position = ancestors_taxonomic_position
    FROM self_and_descendants
    WHERE taxon_concepts.id = self_and_descendants.id;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_taxonomy() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_taxonomy_for_node(NULL);
  END;
  $$;

COMMENT ON FUNCTION rebuild_taxonomy() IS '
Procedure to rebuild the computed full name, rank and ancestor names fields
 in taxon_concepts.';
