class CreateFunctionToRebuildNamesAndRanks < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION rebuild_names_and_ranks() RETURNS void AS $$
        BEGIN
          WITH RECURSIVE q AS (
            SELECT h, h.id, ranks.name as rank_name,
            (ranks.name => taxon_names.scientific_name) AS ancestors
            FROM taxon_concepts h
            INNER JOIN taxon_names ON h.taxon_name_id = taxon_names.id
            INNER JOIN ranks ON h.rank_id = ranks.id
            WHERE h.parent_id IS NULL

            UNION ALL

            SELECT hi, hi.id, ranks.name,
            ancestors || (ranks.name => taxon_names.scientific_name)
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
            INNER JOIN taxon_names ON hi.taxon_name_id = taxon_names.id
            INNER JOIN ranks ON hi.rank_id = ranks.id
          )
          UPDATE taxon_concepts
          SET data = data || ancestors || ('full_name' => 
            CASE 
              WHEN rank_name = 'SPECIES' THEN 
                -- now create a binomen for full name
                CAST(ancestors -> 'GENUS' AS VARCHAR) || ' ' || 
                LOWER(CAST(ancestors -> 'SPECIES' AS VARCHAR))
              WHEN rank_name = 'SUBSPECIES' THEN 
                -- now create a trinomen for full name
                CAST(ancestors -> 'GENUS' AS VARCHAR) || ' ' || 
                LOWER(CAST(ancestors -> 'SPECIES' AS VARCHAR)) ||
                CAST(ancestors -> 'SUBSPECIES' AS VARCHAR)
              ELSE  ancestors -> rank_name END
          ) || ('rank_name' => rank_name)
          FROM q
          WHERE taxon_concepts.id = q.id;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      COMMENT ON FUNCTION rebuild_names_and_ranks() IS
      'Procedure to rebuild the computed full name, rank and ancestor names fields in taxon_concepts.'
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION sapi_rebuild() RETURNS void AS $$
        BEGIN
          RAISE NOTICE 'Rebuilding SAPI database';
          RAISE NOTICE 'taxonomic positions';
          PERFORM rebuild_taxonomic_positions();
          RAISE NOTICE 'names and ranks';
          PERFORM rebuild_names_and_ranks();
          RAISE NOTICE 'TODO';
        END;
      $$ LANGUAGE plpgsql;
    SQL

  end

  def down
    execute "DROP FUNCTION IF EXISTS rebuild_names_and_ranks()"
  end
end
