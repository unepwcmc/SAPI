class CreateFunctionToRebuildAncestorListings < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION rebuild_ancestor_listings() RETURNS void AS $$
        BEGIN
          WITH RECURSIVE q AS (
            SELECT h, id, parent_id, listing
            FROM taxon_concepts h
            WHERE CAST(listing -> 'cites_listing' AS VARCHAR) IS NOT NULL
            
            UNION ALL
            
            SELECT hi, hi.id, hi.parent_id, 
            CASE 
              WHEN hi.listing IS NULL THEN q.listing
              ELSE hi.listing || q.listing
            END
            FROM q
            JOIN    taxon_concepts hi
            ON      hi.id = (q.h).parent_id
          ) 
          UPDATE taxon_concepts
          SET listing = q.listing
          FROM q
          WHERE taxon_concepts.id = q.id;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      COMMENT ON FUNCTION rebuild_ancestor_listings() IS
      'Procedure to rebuild the computed ancestor listings in taxon_concepts.'
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION sapi_rebuild() RETURNS void AS $$
        BEGIN
          RAISE NOTICE 'Rebuilding SAPI database';
          RAISE NOTICE 'taxonomic positions';
          PERFORM rebuild_taxonomic_positions();
          RAISE NOTICE 'names and ranks';
          PERFORM rebuild_names_and_ranks();
          RAISE NOTICE 'listings';
          PERFORM rebuild_listings();
          RAISE NOTICE 'ancestor listings';
          PERFORM rebuild_ancestor_listings();
        END;
      $$ LANGUAGE plpgsql;
    SQL

  end

  def down
    execute "DROP FUNCTION IF EXISTS rebuild_ancestor_listings()"
  end
end
