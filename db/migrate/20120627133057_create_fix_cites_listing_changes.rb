class CreateFixCitesListingChanges < ActiveRecord::Migration
  def up
    execute "ALTER FUNCTION insert_cites_listing_deletions() RENAME TO fix_cites_listing_changes"
    execute <<-SQL
    CREATE OR REPLACE FUNCTION fix_cites_listing_changes() RETURNS void
    LANGUAGE plpgsql
    AS $$
      BEGIN
      INSERT INTO listing_changes 
      (taxon_concept_id, species_listing_id, change_type_id, effective_at, created_at, updated_at)
      SELECT 
      qq.taxon_concept_id, qq.species_listing_id, (SELECT id FROM change_types WHERE name = 'DELETION' LIMIT 1), qq.effective_at - time '00:00:01', NOW(), NOW()
      FROM (
              WITH q AS (
                      SELECT taxon_concept_id, species_listing_id, change_type_id, change_types.name, effective_at, 
                      ROW_NUMBER() OVER(ORDER BY taxon_concept_id, species_listing_id, effective_at) AS row_no
                      FROM listing_changes
                      LEFT JOIN change_types on change_type_id = change_types.id
                      WHERE change_type_id IN (SELECT id FROM change_types WHERE name IN ('ADDITION','DELETION'))
                      AND species_listing_id IN (
                        SELECT species_listings.id FROM species_listings
                        LEFT JOIN designations ON designations.id = species_listings.designation_id
                        WHERE designations.name = 'CITES'
                      )
              )
              SELECT q1.taxon_concept_id, q1.species_listing_id, q2.effective_at
              FROM q q1 LEFT JOIN q q2 ON (q1.taxon_concept_id =q2.taxon_concept_id AND q2.row_no = q1.row_no - 1)
              WHERE q2.taxon_concept_id IS NOT NULL
              AND q1.change_type_id = q2.change_type_id AND q1.change_type_id = (SELECT id FROM change_types WHERE name = 'ADDITION' LIMIT 1)
      ) qq;
      END;
      $$;
    SQL
  end
  def down
    execute "ALTER FUNCTION fix_cites_listing_changes() RENAME TO insert_cites_listing_deletions"
  end
end
