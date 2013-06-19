namespace :import do

  desc 'Import reference synonym links from csv file (usage: rake import:reference_synonym_links[path/to/file,path/to/another])'
  task :reference_synonym_links, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'reference_synonym_links_import'
    puts "There are #{TaxonConceptReference.count} taxon concept references in the database."

    ActiveRecord::Base.connection.execute('DROP INDEX IF EXISTS index_taxon_concepts_on_legacy_id_and_legacy_type')
    ActiveRecord::Base.connection.execute('DROP INDEX IF EXISTS index_references_on_legacy_id_and_legacy_type')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_on_legacy_id_and_legacy_type ON taxon_concepts (legacy_id, legacy_type)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_references_on_legacy_id_and_legacy_type ON "references" (legacy_id, legacy_type)')

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      sql = <<-SQL
        WITH reference_synonym_links AS (
          WITH expanded_ref_ids AS (
            SELECT taxon_legacy_id, rank, accepted_taxon_legacy_id, accepted_rank,
            regexp_split_to_table(ref_legacy_ids, ':') AS ref_legacy_id
            FROM #{TMP_TABLE}
          )-- TODO remove the substring below once files are fixed
          SELECT taxon_legacy_id, rank, accepted_taxon_legacy_id, accepted_rank,
          COALESCE(map.legacy_id, NULLIF(substring(ref_legacy_id from 1 for 5), '')::INTEGER) AS ref_legacy_id
          FROM expanded_ref_ids
          LEFT JOIN references_legacy_id_mapping map
          ON map.alias_legacy_id = NULLIF(substring(ref_legacy_id from 1 for 5), '')::INTEGER
        )
        INSERT INTO "taxon_concept_references" (taxon_concept_id, reference_id, created_at, updated_at)
        SELECT taxon_concepts.id, "references".id, NOW(), NOW()
          FROM reference_synonym_links
          INNER JOIN ranks
            ON UPPER(BTRIM(reference_synonym_links.rank)) = UPPER(ranks.name)
          INNER JOIN taxon_concepts
            ON reference_synonym_links.taxon_legacy_id = taxon_concepts.legacy_id
              AND taxon_concepts.legacy_type = '#{kingdom}'::VARCHAR
              AND taxon_concepts.rank_id = ranks.id
              AND (taxon_concepts.data->'accepted_legacy_id')::INT = accepted_taxon_legacy_id
              AND (taxon_concepts.data->'accepted_rank') = accepted_rank
          INNER JOIN "references"
            ON reference_synonym_links.ref_legacy_id = "references".legacy_id
              AND "references".legacy_type = '#{kingdom}'::VARCHAR
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
    ActiveRecord::Base.connection.execute('DROP INDEX index_taxon_concepts_on_legacy_id_and_legacy_type')
    ActiveRecord::Base.connection.execute('DROP INDEX index_references_on_legacy_id_and_legacy_type')
  end

end
