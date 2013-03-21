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
#create index on distribution_references(distribution_id, reference_id)
      sql = <<-SQL
        WITH unaliased_reference_links AS (
          SELECT UPPER(BTRIM(rank)) AS rank, taxon_legacy_id, UPPER(BTRIM(iso_code2)) AS iso_code2,
          CASE
          WHEN map.legacy_id IS NOT NULL THEN map.legacy_id
          ELSE #{TMP_TABLE}.ref_legacy_id
          END AS ref_legacy_id, '#{kingdom}'::VARCHAR AS legacy_type
          FROM #{TMP_TABLE}
          LEFT JOIN references_legacy_id_mapping map
          ON map.alias_legacy_id = #{TMP_TABLE}.ref_legacy_id AND map.legacy_type = '#{kingdom}'
          WHERE #{TMP_TABLE}.ref_legacy_id IS NOT NULL AND #{TMP_TABLE}.taxon_legacy_id IS NOT NULL
        )
        INSERT INTO "distribution_references"
          (distribution_id, reference_id)
        SELECT distributions.id, "references".id
          FROM unaliased_reference_links
          INNER JOIN ranks
            ON rank = UPPER(ranks.name)
          INNER JOIN taxon_concepts
            ON unaliased_reference_links.taxon_legacy_id = taxon_concepts.legacy_id
              AND unaliased_reference_links.legacy_type = taxon_concepts.legacy_type
              AND taxon_concepts.rank_id = ranks.id
          INNER JOIN "references"
            ON unaliased_reference_links.ref_legacy_id = "references".legacy_id
            AND unaliased_reference_links.legacy_type = "references".legacy_type
          INNER JOIN geo_entities
            ON unaliased_reference_links.iso_code2 = UPPER(geo_entities.iso_code2)
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
