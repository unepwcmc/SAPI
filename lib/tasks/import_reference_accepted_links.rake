namespace :import do

  desc 'Import reference accepted links from csv file (usage: rake import:reference_accepted_links[path/to/file,path/to/another])'
  task :reference_accepted_links, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'reference_accepted_links_import'
    puts "There are #{TaxonConceptReference.count} taxon concept references in the database."

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      sql = <<-SQL
        WITH unaliased_reference_links AS (
          SELECT UPPER(rank) AS rank, taxon_legacy_id,
          CASE
          WHEN map.legacy_id IS NOT NULL THEN map.legacy_id
          ELSE #{TMP_TABLE}.ref_legacy_id
          END AS ref_legacy_id, '#{kingdom}'::VARCHAR AS legacy_type
          FROM #{TMP_TABLE}
          LEFT JOIN references_legacy_id_mapping map
          ON map.alias_legacy_id = #{TMP_TABLE}.ref_legacy_id AND map.legacy_type = '#{kingdom}'
        )
        INSERT INTO "taxon_concept_references" (taxon_concept_id, reference_id)
        SELECT taxon_concepts.id, "references".id
          FROM unaliased_reference_links
          INNER JOIN ranks
            ON unaliased_reference_links.rank = ranks.name
          INNER JOIN taxon_concepts
            ON unaliased_reference_links.taxon_legacy_id = taxon_concepts.legacy_id
              AND taxon_concepts.legacy_type = unaliased_reference_links.legacy_type
              AND taxon_concepts.rank_id = ranks.id
          INNER JOIN "references"
            ON unaliased_reference_links.ref_legacy_id = "references".legacy_id
              AND "references".legacy_type = unaliased_reference_links.legacy_type
          AND NOT EXISTS (
            SELECT id
            FROM taxon_concept_references
            WHERE taxon_concept_id = taxon_concepts.id
              AND reference_id = "references".id
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)

    end
    puts "There are now #{TaxonConceptReference.count} taxon concept references in the database"
  end

end
