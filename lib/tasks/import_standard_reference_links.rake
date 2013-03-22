#Encoding: utf-8

namespace :import do

  desc "Import standard reference links from csv file (usage: rake import:standard_references[path/to/file,path/to/another])"
  task :standard_reference_links, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'standard_reference_links_import'
    puts "There are #{TaxonConceptReference.where("(data->'usr_is_std_ref')::BOOLEAN = 't'").count} standard references in the database."

    ActiveRecord::Base.connection.execute('CREATE INDEX index_taxon_concepts_on_legacy_id_and_legacy_type ON taxon_concepts(legacy_id, legacy_type)')
    ActiveRecord::Base.connection.execute('CREATE INDEX index_references_on_legacy_id_and_legacy_type ON references(legacy_id, legacy_type)')
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

      puts "inserting reference links"
      #add taxon_concept_references where missing
      sql = <<-SQL
        INSERT INTO "taxon_concept_references" (taxon_concept_id, reference_id)
        SELECT taxon_concepts.id, "references".id
          FROM #{TMP_TABLE}
          INNER JOIN ranks
            ON UPPER(BTRIM(#{TMP_TABLE}.rank)) = UPPER(ranks.name)
          INNER JOIN taxon_concepts
            ON #{TMP_TABLE}.taxon_legacy_id = taxon_concepts.legacy_id
              AND taxon_concepts.legacy_type = '#{kingdom}'::VARCHAR
              AND taxon_concepts.rank_id = ranks.id
          INNER JOIN "references"
            ON #{TMP_TABLE}.ref_legacy_id = "references".legacy_id
              AND "references".legacy_type = '#{kingdom}'::VARCHAR
          AND NOT EXISTS (
            SELECT id
            FROM taxon_concept_references
            WHERE taxon_concept_id = taxon_concepts.id
              AND reference_id = "references".id
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)

      puts "updating standard reference links"
      #update usr_std_ref flags
      sql = <<-SQL
      WITH standard_references_as_ids AS (
        WITH standard_references_per_exclusion AS (
          SELECT rank, taxon_legacy_id, ref_legacy_id, '#{kingdom}'::VARCHAR AS legacy_type, "cascade", 
          CASE WHEN exclusions IS NULL THEN NULL ELSE split_part(regexp_split_to_table(exclusions,','),':',1) END AS exclusion_rank,
          CASE WHEN exclusions IS NULL THEN NULL ELSE split_part(regexp_split_to_table(exclusions,','),':',2) END AS exclusion_legacy_id
          FROM #{TMP_TABLE}
        )
        SELECT taxon_concepts.id AS taxon_concept_id,
        ARRAY_AGG(exclusion_taxon_concepts.id)::VARCHAR AS exclusions,
        "references".id AS reference_id, 
        "cascade"
        FROM standard_references_per_exclusion
        INNER JOIN ranks
          ON LOWER(ranks.name) = LOWER(BTRIM(rank))
        LEFT JOIN ranks exclusion_ranks
          ON LOWER(exclusion_ranks.name) = LOWER(BTRIM(exclusion_rank))
        INNER JOIN taxon_concepts
          ON taxon_concepts.legacy_id = taxon_legacy_id
          AND taxon_concepts.legacy_type = standard_references_per_exclusion.legacy_type
          AND taxon_concepts.rank_id = ranks.id
        LEFT JOIN taxon_concepts exclusion_taxon_concepts
          ON exclusion_taxon_concepts.legacy_id = exclusion_legacy_id::INTEGER
          AND exclusion_taxon_concepts.legacy_type = standard_references_per_exclusion.legacy_type
          AND exclusion_taxon_concepts.rank_id = exclusion_ranks.id
        INNER JOIN "references"
          ON "references".legacy_id = standard_references_per_exclusion.ref_legacy_id
          AND "references".legacy_type = standard_references_per_exclusion.legacy_type
        GROUP BY taxon_concept_id, reference_id, "cascade"
      )
      UPDATE taxon_concept_references SET data = hstore('usr_is_std_ref', 't') ||
      hstore('cascade', "cascade"::VARCHAR) ||
      hstore('exclusions', exclusions)
      FROM standard_references_as_ids
      WHERE taxon_concept_references.taxon_concept_id = standard_references_as_ids.taxon_concept_id AND
      taxon_concept_references.reference_id = standard_references_as_ids.reference_id

      SQL
      ActiveRecord::Base.connection.execute(sql)

    end
    puts "There are now #{TaxonConceptReference.where("(data->'usr_is_std_ref')::BOOLEAN = 't'").count} standard references in the database"
    ActiveRecord::Base.connection.execute('DROP INDEX index_taxon_concepts_on_legacy_id_and_legacy_type')
    ActiveRecord::Base.connection.execute('DROP INDEX index_references_on_legacy_id_and_legacy_type')
    Sapi::rebuild_references
  end

end