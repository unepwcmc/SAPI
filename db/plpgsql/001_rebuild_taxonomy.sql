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

CREATE OR REPLACE FUNCTION ancestors_data(node_id INTEGER) RETURNS HSTORE
  LANGUAGE plpgsql
  AS $$
  DECLARE
    result HSTORE;
    ancestor_row RECORD;
  BEGIN
    WITH RECURSIVE q AS (
      SELECT h.id, h.parent_id, h.taxonomic_position, 
        HSTORE(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
        HSTORE(LOWER(ranks.name) || '_id', h.id::VARCHAR) ||
        HSTORE('taxonomic_position', h.taxonomic_position) AS ancestors
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = node_id

      UNION

      SELECT hi.id, hi.parent_id, GREATEST(hi.taxonomic_position, q.taxonomic_position), q.ancestors ||
        HSTORE(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
        HSTORE(LOWER(ranks.name) || '_id', hi.id::VARCHAR)
      FROM q
      JOIN taxon_concepts hi
      ON hi.id = q.parent_id
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    SELECT ancestors || HSTORE('taxonomic_position', q.taxonomic_position)
    INTO result FROM q WHERE parent_id IS NULL;
    RETURN result;
  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_taxonomy_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    WITH RECURSIVE q AS (
      SELECT h.id, ranks.name AS rank_name, ancestors_data(node_id) AS ancestors
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.name_status NOT IN ('S', 'H') AND
        CASE
        WHEN node_id IS NOT NULL THEN h.id = node_id
        ELSE h.parent_id IS NULL
        END

      UNION

      SELECT hi.id, ranks.name,
      ancestors ||
      hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
      hstore(LOWER(ranks.name) || '_id', (hi.id)::VARCHAR) ||
      CASE
        WHEN (ranks.fixed_order) THEN HSTORE('taxonomic_position', hi.taxonomic_position)
        -- use generous zero padding to accommodate for orchidacea (30 thousand species in about 900 genera)
        ELSE HSTORE('taxonomic_position', (q.ancestors->'taxonomic_position' || '.' || LPAD(
          (row_number() OVER (PARTITION BY parent_id ORDER BY full_name)::VARCHAR(64)),
          5,
          '0'
        ))::VARCHAR(255))
      END
      FROM q
      JOIN taxon_concepts hi
      ON hi.parent_id = q.id
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET
    full_name = full_name(rank_name, ancestors),
    taxonomic_position = ancestors->'taxonomic_position',
    data = CASE WHEN data IS NOT NULL THEN data ELSE ''::HSTORE END ||
      ancestors || hstore('rank_name', rank_name)
    FROM q
    WHERE taxon_concepts.id = q.id;
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
