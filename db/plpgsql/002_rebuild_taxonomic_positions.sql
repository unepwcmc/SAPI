--
-- Name: rebuild_taxonomic_positions_from_root(root_id integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_taxonomic_positions_from_root(root_id integer) RETURNS void
  LANGUAGE plpgsql
  AS $$
  BEGIN

    WITH RECURSIVE q AS (
      SELECT h.id, h.taxonomic_position, ranks.fixed_order AS fixed_order
      FROM taxon_concepts h
      INNER JOIN ranks ON h.rank_id = ranks.id
      WHERE h.id = root_id

      UNION ALL

      SELECT hi.id,
      CASE
        WHEN (ranks.fixed_order) THEN hi.taxonomic_position
        -- use generous zero padding to accommodate for orchidacea (30 thousand species in about 900 genera)
        ELSE (q.taxonomic_position || '.' || LPAD(
          (row_number() OVER (PARTITION BY parent_id ORDER BY full_name)::VARCHAR(64)),
          5,
          '0'
        ))::VARCHAR(255)
      END, ranks.fixed_order
      FROM q
      JOIN taxon_concepts hi ON hi.parent_id = q.id
      INNER JOIN ranks ON hi.rank_id = ranks.id
    )
    UPDATE taxon_concepts
    SET taxonomic_position = q.taxonomic_position
    FROM q
    WHERE q.id = taxon_concepts.id;

  END;
  $$;

COMMENT ON FUNCTION rebuild_taxonomic_positions_from_root(root_id integer) IS
'Procedure to rebuild the computed taxonomic position fields in taxon_concepts starting from root given by root_id.';

--
-- Name: rebuild_taxonomic_positions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_taxonomic_positions() RETURNS void
  LANGUAGE plpgsql
  AS $$
  DECLARE
    root_id integer;
  BEGIN

    FOR root_id IN SELECT id FROM taxon_concepts
      WHERE parent_id IS NULL
    LOOP
      PERFORM rebuild_taxonomic_positions_from_root(root_id);
    END LOOP;

  END;
  $$;

COMMENT ON FUNCTION rebuild_taxonomic_positions() IS
'Procedure to rebuild the computed taxonomic position fields in taxon_concepts.';
