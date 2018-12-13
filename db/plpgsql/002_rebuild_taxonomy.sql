
CREATE OR REPLACE FUNCTION ancestor_node_ids_for_node(node_id integer) RETURNS INTEGER[]
  LANGUAGE sql STABLE
  AS $$
    WITH RECURSIVE ancestors AS (
      SELECT h.id, h.parent_id
      FROM taxon_concepts h WHERE id = $1

      UNION

      SELECT hi.id, hi.parent_id
      FROM taxon_concepts hi JOIN ancestors ON hi.id = ancestors.parent_id
    )
    SELECT ARRAY(SELECT id FROM ancestors);
  $$;

CREATE OR REPLACE FUNCTION full_name(rank_name VARCHAR(255), ancestors HSTORE) RETURNS VARCHAR(255)
  LANGUAGE sql IMMUTABLE
  AS $$
  SELECT CASE
      WHEN $1 = 'SPECIES' THEN
        -- now create a binomen for full name
        CAST($2 -> 'genus_name' AS VARCHAR) || ' ' ||
        LOWER(CAST($2 -> 'species_name' AS VARCHAR))
      WHEN $1 = 'SUBSPECIES' THEN
        -- now create a trinomen for full name
        CAST($2 -> 'genus_name' AS VARCHAR) || ' ' ||
        LOWER(CAST($2 -> 'species_name' AS VARCHAR)) || ' ' ||
        LOWER(CAST($2 -> 'subspecies_name' AS VARCHAR))
      WHEN $1 = 'VARIETY' THEN
        -- now create a trinomen for full name
        CAST($2 -> 'genus_name' AS VARCHAR) || ' ' ||
        LOWER(CAST($2 -> 'species_name' AS VARCHAR)) || ' var. ' ||
        LOWER(CAST($2 -> 'variety_name' AS VARCHAR))
      ELSE $2 -> LOWER($1 || '_name')
  END;
  $$;

CREATE OR REPLACE FUNCTION ancestors_names(node_id INTEGER) RETURNS HSTORE
  LANGUAGE sql
  AS $$
    WITH RECURSIVE q AS (
      SELECT h.id, h.parent_id,
        HSTORE(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
        HSTORE(LOWER(ranks.name) || '_id', h.id::VARCHAR) AS ancestors
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = $1

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
    SELECT ancestors FROM q WHERE parent_id IS NULL;
  $$;

CREATE OR REPLACE FUNCTION rebuild_taxonomic_positions_for_animalia_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    -- update taxonomic position
    WITH RECURSIVE self_and_descendants AS (
      SELECT h.id, COALESCE(h.taxonomic_position, '') AS ancestors_taxonomic_position
      FROM taxon_concepts h
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = node_id

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

CREATE OR REPLACE FUNCTION rebuild_taxonomic_positions_for_plantae_node(node_id integer, rank_name text) RETURNS void
  LANGUAGE plpgsql
  AS $$

  BEGIN
    IF rank_name IN ('KINGDOM', 'PHYLUM', 'CLASS', 'ORDER', 'FAMILY')  THEN
      -- rebuild higher taxonomic ranks
      WITH plantae_root AS (
        SELECT taxon_concepts.id, taxonomic_position
        FROM taxon_concepts
        JOIN taxonomies
        ON taxonomies.id = taxon_concepts.taxonomy_id
        AND taxonomies.name = 'CITES_EU'
        WHERE full_name = 'Plantae'
      ), missing_higher_taxa AS (
        UPDATE taxon_concepts
        SET taxonomic_position = plantae_root.taxonomic_position
        FROM plantae_root
        WHERE plantae_root.id = (taxon_concepts.data->'kingdom_id')::INT
        AND data->'rank_name' IN ('PHYLUM', 'CLASS', 'ORDER')
      ), families AS (
        SELECT taxon_concepts.id, plantae_root.taxonomic_position || '.' || LPAD(
          (
            ROW_NUMBER()
            OVER (PARTITION BY rank_id ORDER BY full_name)::VARCHAR(64)
          )::VARCHAR(64),
          5,
          '0'
        ) AS taxonomic_position
        FROM taxon_concepts
        JOIN plantae_root ON plantae_root.id = (taxon_concepts.data->'kingdom_id')::INT
        WHERE data->'rank_name' = 'FAMILY'
      )
      UPDATE taxon_concepts
      SET taxonomic_position = families.taxonomic_position
      FROM families
      WHERE families.id = taxon_concepts.id;
    END IF;

    -- update taxonomic position
    WITH RECURSIVE self_and_descendants AS (
      SELECT h.id,
        COALESCE(h.taxonomic_position, '') AS ancestors_taxonomic_position
      FROM taxon_concepts h
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = node_id

      UNION

      SELECT hi.id,
      CASE
        WHEN hi.data->'rank_name' IN ('PHYLUM', 'CLASS', 'ORDER', 'FAMILY')
        THEN hi.taxonomic_position
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
    WHERE taxon_concepts.id = self_and_descendants.id
    AND taxon_concepts.data->'rank_name' NOT IN ('PHYLUM', 'CLASS', 'ORDER', 'FAMILY');

  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_taxonomic_positions_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    ancestor_kingdom_name text;
    kingdom_node_id integer;
    ancestor_node_id integer;
    ancestor_rank_name text;
  BEGIN
    IF node_id IS NOT NULL THEN
      -- find kingdom for this node
      -- find the closest ancestor with taxonomic position set
      WITH RECURSIVE self_and_ancestors AS (
          SELECT h.id, h.parent_id, h.taxonomic_position, 1 AS level,
            h.data->'kingdom_name' AS kingdom_name,
            h.data->'rank_name' AS rank_name
          FROM taxon_concepts h
          WHERE id = node_id

          UNION

          SELECT hi.id, hi.parent_id, hi.taxonomic_position, level + 1,
            hi.data->'kingdom_name', hi.data->'rank_name'
          FROM taxon_concepts hi
          JOIN self_and_ancestors ON self_and_ancestors.parent_id = hi.id
      )
      SELECT id, rank_name, kingdom_name INTO ancestor_node_id, ancestor_rank_name, ancestor_kingdom_name
      FROM self_and_ancestors
      WHERE taxonomic_position IS NOT NULL AND id != node_id
      ORDER BY level
      LIMIT 1;
      -- and rebuild animalia or plantae subtree
      IF ancestor_kingdom_name = 'Animalia' THEN
        PERFORM rebuild_taxonomic_positions_for_animalia_node(ancestor_node_id);
      ELSE
        PERFORM rebuild_taxonomic_positions_for_plantae_node(ancestor_node_id, ancestor_rank_name);
      END IF;
    ELSE
      -- rebuild animalia and plantae trees separately
      -- CITES Animalia
      SELECT taxon_concepts.id INTO kingdom_node_id
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id
      AND taxonomies.name = 'CITES_EU'
      WHERE full_name = 'Animalia';
      PERFORM rebuild_taxonomic_positions_for_animalia_node(kingdom_node_id);
      -- CMS Animalia
      SELECT taxon_concepts.id INTO kingdom_node_id
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id
      AND taxonomies.name = 'CMS'
      WHERE full_name = 'Animalia';
      PERFORM rebuild_taxonomic_positions_for_animalia_node(kingdom_node_id);
      -- CITES Plantae
      SELECT taxon_concepts.id INTO kingdom_node_id
      FROM taxon_concepts
      JOIN taxonomies
      ON taxonomies.id = taxon_concepts.taxonomy_id
      AND taxonomies.name = 'CITES_EU'
      WHERE full_name = 'Plantae';
      PERFORM rebuild_taxonomic_positions_for_plantae_node(kingdom_node_id, 'KINGDOM');
    END IF;

  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_taxonomy_for_node(node_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    -- update rank name
    UPDATE taxon_concepts
    SET data = COALESCE(taxon_concepts.data, ''::HSTORE) || HSTORE('rank_name', ranks.name)
    FROM taxon_concepts q
    JOIN ranks ON q.rank_id = ranks.id
    WHERE taxon_concepts.id = q.id
      AND CASE
        WHEN node_id IS NOT NULL THEN taxon_concepts.id = node_id
        ELSE TRUE
      END;

    -- update full name
    WITH RECURSIVE q AS (
      SELECT h.id, ranks.name AS rank_name, ancestors_names(h.id) AS ancestors_names
      FROM taxon_concepts h
      INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE name_status IN ('A', 'N') AND
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
      ON hi.parent_id = q.id AND hi.name_status IN ('A', 'N')
      INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET
    data = COALESCE(data, ''::HSTORE) || ancestors_names
    FROM q
    WHERE taxon_concepts.id = q.id;

    -- do not recalculate position for individual node
    -- as it takes too long to run on insert trigger
    IF node_id IS NULL THEN
      PERFORM rebuild_taxonomic_positions_for_node(node_id);
    END IF;

  END;
  $$;

CREATE OR REPLACE FUNCTION rebuild_taxonomy() RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN
    PERFORM rebuild_taxonomy_for_node(NULL);
    REFRESH MATERIALIZED VIEW taxon_concepts_and_ancestors_mview;
  END;
  $$;

COMMENT ON FUNCTION rebuild_taxonomy() IS '
Procedure to rebuild the computed full name, rank and ancestor names fields
 in taxon_concepts.';
