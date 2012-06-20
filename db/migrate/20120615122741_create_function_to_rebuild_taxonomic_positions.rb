class CreateFunctionToRebuildTaxonomicPositions < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION rebuild_taxonomic_positions() RETURNS void AS $$
        BEGIN
        WITH RECURSIVE q AS (
          SELECT h, id,
          data->'taxonomic_position' AS taxonomic_position
          FROM taxon_concepts h
          WHERE parent_id IS NULL

          UNION ALL

          SELECT hi, hi.id,
          CASE
            WHEN CAST(data -> 'taxonomic_position' AS VARCHAR) IS NOT NULL THEN data -> 'taxonomic_position'
            -- use generous zero padding to accommodate for orchidacea (30 thousand species in about 900 genera)
            ELSE q.taxonomic_position || '.' || LPAD(
              CAST(row_number() OVER (PARTITION BY parent_id ORDER BY data->'full_name') AS VARCHAR),
              5,
              '0'
            )
          END
        
          FROM q
          JOIN    taxon_concepts hi
          ON      hi.parent_id = (q.h).id
        )
        UPDATE taxon_concepts
        SET data = CASE
          WHEN data IS NULL THEN ('taxonomic_position' => taxonomic_position)
          ELSE data || ('taxonomic_position' => taxonomic_position) END
        FROM q
        WHERE q.id = taxon_concepts.id;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      COMMENT ON FUNCTION rebuild_taxonomic_positions() IS
      'Procedure to rebuild the computed taxonomic position fields in taxon_concepts.'
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION sapi_rebuild() RETURNS void AS $$
        BEGIN
          RAISE NOTICE 'Rebuilding SAPI database';
          RAISE NOTICE 'taxonomic positions';
          PERFORM rebuild_taxonomic_positions();
          RAISE NOTICE 'TODO';
        END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute "DROP FUNCTION IF EXISTS rebuild_taxonomic_positions()"
  end
end
