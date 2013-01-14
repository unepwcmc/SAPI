#Encoding: utf-8

namespace :import do

  desc "Import standard references records from csv file (usage: rake import:standard_references[path/to/file,path/to/another])"
  task :standard_references, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    tmp_table = 'standard_references_import'
    puts "There are #{TaxonConceptReference.where("(data->'usr_is_std_ref')::BOOLEAN = 't'").count} standard references in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(tmp_table)
      create_table_from_csv_headers(file, tmp_table)
      copy_data(file, tmp_table)
      legacy_type = "Animalia"

      #insert stub references where missing
      sql = <<-SQL
        INSERT INTO "references" (legacy_id, legacy_type, title, created_at, updated_at)
        SELECT DISTINCT ref_legacy_id, '#{legacy_type}', 'TODO', NOW(), NOW()
        FROM standard_references_import
        WHERE NOT EXISTS (
          SELECT * FROM "references"
          WHERE "references".legacy_id = ref_legacy_id
        )
      SQL

      ActiveRecord::Base.connection.execute(sql)

      #add taxon_concept_references where missing
      sql = <<-SQL
      INSERT INTO taxon_concept_references (taxon_concept_id, reference_id, data)
      SELECT * FROM (
      WITH standard_references_as_ids AS (
        WITH standard_references_import_per_exclusion AS (
          SELECT name, rank, taxon_legacy_id, ref_legacy_id, "cascade", 
          CASE WHEN exclusions IS NULL THEN NULL ELSE split_part(regexp_split_to_table(exclusions,','),':',1) END AS exclusion_rank,
          CASE WHEN exclusions IS NULL THEN NULL ELSE split_part(regexp_split_to_table(exclusions,','),':',2) END AS exclusion_legacy_id
          FROM standard_references_import
        )
        SELECT --standard_references_import_per_exclusion.*,
        taxon_concepts.id AS taxon_concept_id,-- ranks.id AS original_rank_id, ranks.name, taxon_concepts.rank_id AS actual_rank_id, taxon_concepts.full_name AS full_name,
        exclusion_taxon_concepts.id AS exclusion_id,-- exclusion_ranks.name, exclusion_taxon_concepts.full_name AS exclusion_name,
        "references".id AS reference_id, 
        "cascade"
        FROM standard_references_import_per_exclusion
        INNER JOIN ranks
          ON LOWER(ranks.name) = LOWER(rank)
        LEFT JOIN ranks exclusion_ranks
          ON LOWER(exclusion_ranks.name) = LOWER(exclusion_rank)
        INNER JOIN taxon_concepts
          ON taxon_concepts.legacy_id = taxon_legacy_id
          AND taxon_concepts.legacy_type = 'Animalia'
          AND taxon_concepts.rank_id = ranks.id
        LEFT JOIN taxon_concepts exclusion_taxon_concepts
          ON exclusion_taxon_concepts.legacy_id = exclusion_legacy_id::INTEGER
          AND exclusion_taxon_concepts.legacy_type = 'Animalia'
          AND exclusion_taxon_concepts.rank_id = exclusion_ranks.id
        INNER JOIN "references"
          ON "references".legacy_id = standard_references_import_per_exclusion.ref_legacy_id
          AND "references".legacy_type = 'Animalia'
      )
      SELECT taxon_concept_id, reference_id, hstore('usr_is_std_ref', 't') || hstore('cascade', "cascade"::VARCHAR) || hstore('exclusions', ARRAY_AGG(exclusion_id)::VARCHAR)
      FROM standard_references_as_ids
      GROUP BY taxon_concept_id, reference_id, "cascade"
      ) long_subquery
      WHERE NOT EXISTS (
        SELECT * FROM taxon_concept_references
        WHERE taxon_concept_id = long_subquery.taxon_concept_id
        AND reference_id = long_subquery.reference_id
      )
      SQL

      ActiveRecord::Base.connection.execute(sql)

      # #set the no_std_ref flag for exclusions
      # #unless they have their own standard references defined
# 
      # sql = <<-SQL
      # UPDATE taxon_concepts
      # SET data = data || hstore('usr_no_std_ref', 't')
      # FROM (
        # SELECT taxon_concepts.id FROM (
          # SELECT split_part(regexp_split_to_table(exclusions,','),':',1) AS exclusion_rank,
            # split_part(regexp_split_to_table(exclusions,','),':',2) AS exclusion_legacy_id
          # FROM standard_references_import
        # ) exclusions
        # INNER JOIN ranks
        # ON LOWER(ranks.name) = LOWER(exclusion_rank)
        # INNER JOIN taxon_concepts
          # ON taxon_concepts.legacy_id = exclusion_legacy_id::INTEGER
          # AND taxon_concepts.legacy_type = '#{legacy_type}'
          # AND taxon_concepts.rank_id = ranks.id
# 
        # EXCEPT
# 
        # SELECT taxon_concept_id
        # FROM taxon_concept_references
        # WHERE (taxon_concept_references.data->'usr_is_std_ref')::BOOLEAN = 't'
      # ) q WHERE q.id = taxon_concepts.id
      # SQL
# 
      # ActiveRecord::Base.connection.execute(sql)
# 
      # #set the no_std_ref flag for all descendants of taxa with cascade set to false
      # #unless they have their own standard references defined
      # sql = <<-SQL
      # UPDATE taxon_concepts
      # SET data = data || hstore('usr_no_std_ref', 't')
      # FROM (
        # WITH RECURSIVE no_cascade AS (
          # SELECT h, h.id
          # FROM standard_references_import
          # INNER JOIN ranks
            # ON LOWER(ranks.name) = LOWER(standard_references_import.rank)
          # INNER JOIN taxon_concepts h
            # ON h.legacy_id = standard_references_import.taxon_legacy_id
            # AND h.legacy_type = '#{legacy_type}'
            # AND h.rank_id = ranks.id
          # WHERE NOT "cascade"
# 
          # UNION ALL
# 
          # SELECT hi, hi.id
          # FROM no_cascade
          # JOIN taxon_concepts hi
          # ON hi.parent_id = (no_cascade.h).id
        # )
        # SELECT id FROM no_cascade
# 
        # EXCEPT
# 
        # SELECT taxon_concept_id
        # FROM taxon_concept_references
        # WHERE (taxon_concept_references.data->'usr_is_std_ref')::BOOLEAN = 't'
      # ) q WHERE q.id = taxon_concepts.id
      # SQL
# 
      # ActiveRecord::Base.connection.execute(sql)

    end
    puts "There are now #{TaxonConceptReference.where("(data->'usr_is_std_ref')::BOOLEAN = 't'").count} standard references in the database"
    Sapi::rebuild_references
  end

end