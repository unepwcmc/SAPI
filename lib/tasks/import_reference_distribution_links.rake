namespace :import do

  desc 'Import reference distribution links from csv file (usage: rake import:reference_distribution_links[path/to/file,path/to/another])'
  task :reference_distribution_links, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'reference_distribution_links_import'
    puts "There are #{TaxonConceptGeoEntityReference.count} taxon concept geo entity references in the database."

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      sql = <<-SQL
        INSERT INTO "distribution_references"
          (distribution_id, reference_id)
        SELECT distributions.id, "references".id
          FROM #{TMP_TABLE}
          INNER JOIN ranks
            ON #{TMP_TABLE}.rank = ranks.name
          INNER JOIN taxon_concepts
            ON #{TMP_TABLE}.SpcRecID = taxon_concepts.legacy_id
              AND taxon_concepts.rank_id = ranks.id
              AND #{TMP_TABLE}.legacy_type = taxon_concepts.legacy_type
          INNER JOIN "references"
            ON #{TMP_TABLE}.ref_legacy_id = "references".legacy_id
            AND "references".legacy_type = #{TMP_TABLE}.legacy_type
          INNER JOIN geo_entities
            ON #{TMP_TABLE}.iso_code2 = geo_entities.iso_code2
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
    puts "There are now #{TaxonConceptGeoEntityReference.count} taxon concept geo entity references in the database"
  end

end
