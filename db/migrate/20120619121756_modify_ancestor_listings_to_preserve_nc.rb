class ModifyAncestorListingsToPreserveNc < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION rebuild_ancestor_listings() RETURNS void AS $$
        BEGIN
          WITH qq AS (
            WITH RECURSIVE q AS (
              SELECT h, id, listing
              FROM taxon_concepts h

              UNION ALL

              SELECT hi, hi.id,
              CASE 
                WHEN hi.listing IS NULL THEN q.listing
                ELSE hi.listing || q.listing
              END
              FROM taxon_concepts hi
              INNER JOIN    q
              ON      hi.id = (q.h).parent_id
            )
            SELECT id,
            ('cites_I' => MAX((listing -> 'cites_I')::VARCHAR)) ||
            ('cites_II' => MAX((listing -> 'cites_II')::VARCHAR)) ||
            ('cites_III' => MAX((listing -> 'cites_III')::VARCHAR)) ||
            ('not_in_cites' => MAX((listing -> 'not_in_cites')::VARCHAR)) ||
            ('cites_listing' => ARRAY_TO_STRING(
              -- unnest to filter out the nulls
              ARRAY(SELECT * FROM UNNEST(
                ARRAY[
                  MAX((listing -> 'cites_I')::VARCHAR),
                  MAX((listing -> 'cites_II')::VARCHAR),
                  MAX((listing -> 'cites_III')::VARCHAR),
                  MAX((listing -> 'not_in_cites')::VARCHAR)
                ]) s WHERE s IS NOT NULL),
                '/'
              )
            ) AS listing
            FROM q 
            GROUP BY (id)
          )
          UPDATE taxon_concepts
          SET listing = qq.listing
          FROM qq
          WHERE taxon_concepts.id = qq.id;
        END;
      $$ LANGUAGE plpgsql;
    SQL
  end
end
