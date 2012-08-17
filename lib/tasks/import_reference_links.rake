namespace :import do

  desc 'Import reference links from SQL Server [usage: rake import:reference_links]'
  task :reference_links => [:environment] do
    ANIMALS_QUERY = <<-SQL
      SELECT
          [DslRecID]
          ,[DslSpcRecID]
          ,[DslDscRecID]
          ,[DslCode]
          ,[DslCodeRecID]
      FROM ORWELL.[Animals].[dbo].[DataSourceLink]
      WHERE DslSpcRecID IS NOT NULL
    SQL
    PLANTS_QUERY = <<-SQL
      SELECT
          [DslRecID]
          ,[DslSpcRecID]
          ,[DslDscRecID]
          ,[DslCode]
          ,[DslCodeRecID]
      FROM ORWELL.[Plants].[dbo].[DataSourceLink]
      WHERE DslSpcRecID IS NOT NULL
    SQL
    puts "There are #{TaxonConceptReference.count} taxon concept references in the database."
    puts "There are #{TaxonConceptGeoEntityReference.count} taxon concept geo entity references in the database."
    TMP_TABLE = 'reference_links_import'
    ["animals", "plants"].each do |t|
      drop_table(TMP_TABLE)
      create_import_table(TMP_TABLE)
      query = "#{t.upcase}_QUERY".constantize
      copy_data_in_batches(TMP_TABLE, query, 'DslRecID')
      #copy 'SPC' links
      sql = <<-SQL
        INSERT INTO "taxon_concept_references" (taxon_concept_id, reference_id)
        SELECT taxon_concepts.id, "references".id
          FROM #{TMP_TABLE}
          INNER JOIN taxon_concepts
            ON #{TMP_TABLE}.DslSpcRecID = taxon_concepts.legacy_id
          INNER JOIN "references"
            ON #{TMP_TABLE}.DslDscRecID = "references".legacy_id
              AND "references".legacy_type = '#{t}'
          WHERE DslCode= 'SPC'
          AND NOT EXISTS (
            SELECT id
            FROM taxon_concept_references
            WHERE taxon_concept_id = taxon_concepts.id
              AND reference_id = "references".id
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)

      # copy 'CTY' links
      sql = <<-SQL
        INSERT INTO "taxon_concept_geo_entity_references"
          (taxon_concept_geo_entity_id, reference_id)
        SELECT taxon_concept_geo_entities.id, "references".id
          FROM #{TMP_TABLE}
          INNER JOIN taxon_concepts
            ON #{TMP_TABLE}.DslSpcRecID = taxon_concepts.legacy_id
          INNER JOIN "references"
            ON #{TMP_TABLE}.DslDscRecID = "references".legacy_id AND
              "references".legacy_type = '#{t}'
          INNER JOIN geo_entities
            ON #{TMP_TABLE}.DslCodeRecID = geo_entities.legacy_id
          INNER JOIN taxon_concept_geo_entities
            ON geo_entities.id = taxon_concept_geo_entities.geo_entity_id
          WHERE DslCode= 'CTY'
          AND NOT EXISTS (
            SELECT id
            FROM taxon_concept_geo_entity_references
            WHERE taxon_concept_id = taxon_concepts.id
              AND reference_id = "references".id
              AND geo_entity_id = geo_entities.id
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{TaxonConceptReference.count} taxon concept references in the database"
    puts "There are now #{TaxonConceptGeoEntityReference.count} taxon concept geo entity references in the database"
  end

end