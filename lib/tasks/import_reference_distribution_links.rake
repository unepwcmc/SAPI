namespace :import do

  desc 'Import reference distribution links from csv file (usage: rake import:reference_distribution_links[path/to/file,path/to/another])'
  task :reference_distribution_links, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'reference_distribution_links_import'
    puts "There are #{DistributionReference.count} distribution references in the database."

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      puts "unaliasing reference ids in #{TMP_TABLE}"
      sql = <<-SQL
        UPDATE #{TMP_TABLE} SET ref_legacy_id = map.legacy_id
        FROM references_legacy_id_mapping map
        WHERE map.alias_legacy_id = #{TMP_TABLE}.ref_legacy_id
      SQL
      ActiveRecord::Base.connection.execute(sql)

      puts "inserting reference distribution links"
      sql = <<-SQL
        INSERT INTO "distribution_references"
          (distribution_id, reference_id)
        SELECT distributions.id, "references".id
          FROM #{TMP_TABLE}
          INNER JOIN ranks
            ON UPPER(BTRIM(rank)) = UPPER(ranks.name)
          INNER JOIN taxon_concepts
            ON #{TMP_TABLE}.taxon_legacy_id = taxon_concepts.legacy_id
              AND taxon_concepts.legacy_type = '#{kingdom}'::VARCHAR
              AND taxon_concepts.rank_id = ranks.id
          INNER JOIN "references"
            ON #{TMP_TABLE}.ref_legacy_id = "references".legacy_id
            AND "references".legacy_type = '#{kingdom}'::VARCHAR
          INNER JOIN geo_entities
            ON #{TMP_TABLE}.iso_code2 = UPPER(geo_entities.iso_code2)
          INNER JOIN distributions
            ON geo_entities.id = distributions.geo_entity_id
            AND taxon_concepts.id = distributions.taxon_concept_id
          AND NOT EXISTS (
            SELECT id
            FROM distribution_references
            WHERE reference_id = "references".id
              AND distribution_id = distributions.id
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{DistributionReference.count} distribution references in the database"
  end

end
