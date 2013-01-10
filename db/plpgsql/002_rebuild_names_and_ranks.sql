--
-- Name: rebuild_names_and_ranks(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE OR REPLACE FUNCTION rebuild_names_and_ranks() RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
	  UPDATE taxon_concepts SET data = ''::HSTORE WHERE data IS NULL;

          WITH RECURSIVE q AS (
            SELECT h, h.id, ranks.name as rank_name,
            hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
            hstore(LOWER(ranks.name) || '_id', (h.id)::VARCHAR) AS ancestors
            FROM taxon_concepts h
            INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
            INNER JOIN ranks ON h.rank_id = ranks.id
            WHERE h.parent_id IS NULL

            UNION ALL

            SELECT hi, hi.id, ranks.name,
            ancestors ||
            hstore(LOWER(ranks.name) || '_name', taxon_names.scientific_name) ||
            hstore(LOWER(ranks.name) || '_id', (hi.id)::VARCHAR)
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
            INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
            INNER JOIN ranks ON hi.rank_id = ranks.id
          )
          UPDATE taxon_concepts
          SET data = data || ancestors || hstore('full_name',
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
            END
          ) || hstore('rank_name', rank_name)
          FROM q
          WHERE taxon_concepts.id = q.id;
        END;
      $$;


--
-- Name: FUNCTION rebuild_names_and_ranks(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION rebuild_names_and_ranks() IS 'Procedure to rebuild the computed full name, rank and ancestor names fields in taxon_concepts.';
