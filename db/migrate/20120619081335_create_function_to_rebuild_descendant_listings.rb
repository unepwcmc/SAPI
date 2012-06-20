class CreateFunctionToRebuildDescendantListings < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION rebuild_descendant_listings() RETURNS void AS $$
        BEGIN
          WITH RECURSIVE q AS (
            SELECT h, id, listing
            FROM taxon_concepts h
            WHERE parent_id IS NULL

            UNION ALL

            SELECT hi, hi.id, CASE
              WHEN CAST(hi.listing -> 'cites_listing' AS VARCHAR) IS NOT NULL THEN hi.listing
              WHEN  hi.listing IS NOT NULL THEN hi.listing || q.listing
              ELSE q.listing
            END
            FROM q
            JOIN taxon_concepts hi
            ON hi.parent_id = (q.h).id
          )
          UPDATE taxon_concepts
          SET listing = q.listing
          FROM q
          WHERE taxon_concepts.id = q.id;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      COMMENT ON FUNCTION rebuild_descendant_listings() IS
      'Procedure to rebuild the computed descendant listings in taxon_concepts.'
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
          RAISE NOTICE 'descendant listings';
          PERFORM rebuild_descendant_listings();
          RAISE NOTICE 'ancestor listings';
          PERFORM rebuild_ancestor_listings();
        END;
      $$ LANGUAGE plpgsql;
    SQL

  end

  def down
    execute "DROP FUNCTION IF EXISTS rebuild_descendant_listings()"
  end
end
