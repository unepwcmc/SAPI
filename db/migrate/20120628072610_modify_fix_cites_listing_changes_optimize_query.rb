class ModifyFixCitesListingChangesOptimizeQuery < ActiveRecord::Migration
  def change
    execute <<-SQL
    CREATE OR REPLACE FUNCTION fix_cites_listing_changes() RETURNS void
    LANGUAGE plpgsql
    AS $$
      BEGIN
      INSERT INTO listing_changes 
      (taxon_concept_id, species_listing_id, change_type_id, effective_at, created_at, updated_at)
      SELECT 
      qq.taxon_concept_id, qq.species_listing_id, (SELECT id FROM change_types WHERE name = 'DELETION' LIMIT 1),
      qq.effective_at - time '00:00:01', NOW(), NOW()
      FROM (
             WITH q AS (
                      SELECT taxon_concept_id, species_listing_id, change_type_id, effective_at, change_types.name AS change_type_name,
                      ROW_NUMBER() OVER(ORDER BY taxon_concept_id, effective_at) AS row_no
                      FROM listing_changes
                      LEFT JOIN change_types on change_type_id = change_types.id
                      LEFT JOIN species_listings on species_listing_id = species_listings.id
                      LEFT JOIN designations ON designations.id = species_listings.designation_id
                      WHERE change_types.name IN ('ADDITION','DELETION')
                      AND designations.name = 'CITES'
              )
              SELECT q1.taxon_concept_id, q1.species_listing_id, q2.effective_at
              FROM q q1 LEFT JOIN q q2 ON (q1.taxon_concept_id = q2.taxon_concept_id AND q2.row_no = q1.row_no + 1)
              WHERE q2.taxon_concept_id IS NOT NULL
              AND q1.change_type_id = q2.change_type_id AND q1.change_type_name = 'ADDITION'
      ) qq;
      END;
      $$;
    SQL
  end
end
