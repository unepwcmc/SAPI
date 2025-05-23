namespace :import do
  desc 'Import reference accepted links from csv file (usage: rake import:reference_accepted_links[path/to/file,path/to/another])'
  task :reference_accepted_links, 10.times.map { |i| :"file_#{i}" } => [ :environment ] do |t, args|
    import_helper = CsvImportHelper.new

    TMP_TABLE = 'reference_accepted_links_import'

    puts "There are #{TaxonConceptReference.count} taxon concept references in the database."

    ApplicationRecord.connection.execute('DROP INDEX IF EXISTS index_taxon_concepts_on_legacy_id_and_legacy_type')
    ApplicationRecord.connection.execute('DROP INDEX IF EXISTS index_references_on_legacy_id_and_legacy_type')
    ApplicationRecord.connection.execute('CREATE INDEX index_taxon_concepts_on_legacy_id_and_legacy_type ON taxon_concepts (legacy_id, legacy_type)')
    ApplicationRecord.connection.execute('CREATE INDEX index_references_on_legacy_id_and_legacy_type ON "references" (legacy_id, legacy_type)')

    files = import_helper.files_from_args(t, args)

    files.each do |file|
      import_helper.drop_table(TMP_TABLE)
      import_helper.create_table_from_csv_headers(file, TMP_TABLE)
      import_helper.copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      sql = <<-SQL
        WITH reference_accepted_links AS (
          WITH expanded_ref_ids AS (
            SELECT taxon_legacy_id, rank, regexp_split_to_table(ref_legacy_ids, ':') AS ref_legacy_id
            FROM #{TMP_TABLE}
          )-- TODO remove the substring below once files are fixed
          SELECT taxon_legacy_id, rank,
          COALESCE(map.legacy_id, NULLIF(substring(ref_legacy_id from 1 for 5), '')::INTEGER) AS ref_legacy_id
          FROM expanded_ref_ids
          LEFT JOIN references_legacy_id_mapping map
          ON map.alias_legacy_id = NULLIF(substring(ref_legacy_id from 1 for 5), '')::INTEGER
        )
        INSERT INTO "taxon_concept_references" (taxon_concept_id, reference_id, created_at, updated_at)
        SELECT taxon_concepts.id, "references".id, NOW(), NOW()
          FROM reference_accepted_links
          INNER JOIN ranks
            ON UPPER(BTRIM(reference_accepted_links.rank)) = UPPER(ranks.name)
          INNER JOIN taxon_concepts
            ON reference_accepted_links.taxon_legacy_id = taxon_concepts.legacy_id
              AND taxon_concepts.legacy_type = '#{kingdom}'::VARCHAR
              AND taxon_concepts.rank_id = ranks.id
          INNER JOIN "references"
            ON reference_accepted_links.ref_legacy_id = "references".legacy_id
              AND "references".legacy_type = '#{kingdom}'::VARCHAR
          AND NOT EXISTS (
            SELECT id
            FROM taxon_concept_references
            WHERE taxon_concept_id = taxon_concepts.id
              AND reference_id = "references".id
          )
      SQL

      ApplicationRecord.connection.execute(sql)
    end

    puts "There are now #{TaxonConceptReference.count} taxon concept references in the database"

    ApplicationRecord.connection.execute('DROP INDEX index_taxon_concepts_on_legacy_id_and_legacy_type')
    ApplicationRecord.connection.execute('DROP INDEX index_references_on_legacy_id_and_legacy_type')
  end
end
