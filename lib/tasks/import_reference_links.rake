namespace :import do

  desc 'Import reference links from SQL Server (usage: rake import:reference_links[path/to/file,path/to/another])'
  task :reference_links, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'reference_links_import'
    puts "There are #{TaxonConceptReference.count} taxon concept references in the database."
    puts "There are #{TaxonConceptGeoEntityReference.count} taxon concept geo entity references in the database."

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)
      #copy 'SPC' links
      sql = <<-SQL
        INSERT INTO "taxon_concept_references" (taxon_concept_id, reference_id)
        SELECT taxon_concepts.id, "references".id
          FROM #{TMP_TABLE}
          INNER JOIN taxon_concepts
            ON #{TMP_TABLE}.SpcRecID = taxon_concepts.legacy_id
              AND #{TMP_TABLE}.legacy_type = taxon_concepts.legacy_type
          INNER JOIN "references"
            ON #{TMP_TABLE}.DscRecID = "references".legacy_id
              AND "references".legacy_type = #{TMP_TABLE}.legacy_type
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
        INSERT INTO "distribution_references"
          (distribution_id, reference_id)
        SELECT distributions.id, "references".id
          FROM #{TMP_TABLE}
          INNER JOIN taxon_concepts
            ON #{TMP_TABLE}.SpcRecID = taxon_concepts.legacy_id
              AND #{TMP_TABLE}.legacy_type = taxon_concepts.legacy_type
          INNER JOIN "references"
            ON #{TMP_TABLE}.DscRecID = "references".legacy_id
            AND "references".legacy_type = #{TMP_TABLE}.legacy_type
          INNER JOIN geo_entities
            ON #{TMP_TABLE}.DslCodeRecID = geo_entities.legacy_id
          INNER JOIN distributions
            ON geo_entities.id = distributions.geo_entity_id
          WHERE DslCode= 'CTY'
          AND NOT EXISTS (
            SELECT id
            FROM distribution_references
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
