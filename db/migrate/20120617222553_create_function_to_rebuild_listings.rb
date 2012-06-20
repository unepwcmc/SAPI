class CreateFunctionToRebuildListings < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION rebuild_listings() RETURNS void AS $$
        BEGIN
        UPDATE taxon_concepts
        SET listing = qqq.listing
        FROM (
          SELECT taxon_concept_id, listing ||
          ('cites_listing' => ARRAY_TO_STRING(
            -- unnest to filter out the nulls
            ARRAY(SELECT * FROM UNNEST(
              ARRAY[listing -> 'cites_I', listing -> 'cites_II', listing -> 'cites_III']) s WHERE s IS NOT NULL),
              '/'
            )
          ) AS listing
          FROM (
            SELECT taxon_concept_id, 
              ('cites_I' => CASE WHEN SUM(cites_I) > 0 THEN 'I' ELSE NULL END) ||
              ('cites_II' => CASE WHEN SUM(cites_II) > 0 THEN 'II' ELSE NULL END) ||
              ('cites_III' => CASE WHEN SUM(cites_III) > 0 THEN 'III' ELSE NULL END)
              AS listing
            FROM (
              SELECT taxon_concept_id, effective_at, species_listings.abbreviation, change_types.name AS change_type,
              CASE
                WHEN species_listings.abbreviation = 'I' AND change_types.name = 'ADDITION' THEN 1
                WHEN species_listings.abbreviation = 'I' AND change_types.name = 'DELETION' THEN -1
                ELSE 0
              END AS cites_I,
              CASE
                WHEN species_listings.abbreviation = 'II' AND change_types.name = 'ADDITION' THEN 1
                WHEN species_listings.abbreviation = 'II' AND change_types.name = 'DELETION' THEN -1
                ELSE 0
              END AS cites_II,
              CASE
                WHEN species_listings.abbreviation = 'III' AND change_types.name = 'ADDITION' THEN 1
                WHEN species_listings.abbreviation = 'III' AND change_types.name = 'DELETION' THEN -1
                ELSE 0
              END AS cites_III
              FROM listing_changes 
              LEFT JOIN species_listings on species_listing_id = species_listings.id
              LEFT JOIN change_types on change_type_id = change_types.id
              AND change_types.name IN ('ADDITION','DELETION')
              AND effective_at <= NOW()
            ) AS q
            GROUP BY taxon_concept_id
          ) AS qq
        ) AS qqq
        WHERE taxon_concepts.id = qqq.taxon_concept_id;
        END;
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      COMMENT ON FUNCTION rebuild_listings() IS
      'Procedure to rebuild the computed listings in taxon_concepts.'
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
        END;
      $$ LANGUAGE plpgsql;
    SQL

  end

  def down
    execute "DROP FUNCTION IF EXISTS rebuild_listings()"
  end
end
