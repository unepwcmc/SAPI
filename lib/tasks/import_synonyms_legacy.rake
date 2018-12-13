namespace :import do

  desc 'Import synonyms from csv file (usage: rake import:synonyms[path/to/file,path/to/another])'
  task :synonyms_legacy, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'synonym_import_legacy'
    puts "There are #{TaxonRelationship.
      joins(:taxon_relationship_type).
      where(
        "taxon_relationship_types.name" => TaxonRelationshipType::HAS_SYNONYM
      ).count} synonyms in the database."

    rel = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      # [BEGIN]copied over from import:species_legacy
      import_data_with_legacy_for kingdom, Rank::PHYLUM, true
      import_data_with_legacy_for kingdom, Rank::CLASS, true
      import_data_with_legacy_for kingdom, Rank::ORDER, true
      import_data_with_legacy_for kingdom, Rank::FAMILY, true
      import_data_with_legacy_for kingdom, Rank::SUBFAMILY, true
      import_data_with_legacy_for kingdom, Rank::GENUS, true
      import_data_with_legacy_for kingdom, Rank::SPECIES, true
      import_data_with_legacy_for kingdom, Rank::SUBSPECIES, true
      if kingdom == 'Plantae'
        import_data_with_legacy_for kingdom, Rank::VARIETY
      end
      # [END]copied over from import:species

      [Taxonomy::CITES_EU, Taxonomy::CMS].each do |taxonomy_name|
        puts "Import #{taxonomy_name} taxa"
        taxonomy = Taxonomy.find_by_name(taxonomy_name)
        sql = <<-SQL
          INSERT INTO taxon_relationships(taxon_relationship_type_id,
            taxon_concept_id, other_taxon_concept_id,
            created_at, updated_at)
          SELECT DISTINCT #{rel.id}, accepted_id, synonym_id, current_date, current_date
          FROM (
            SELECT accepted.id AS accepted_id, synonym.id AS synonym_id
            FROM #{TMP_TABLE}
            INNER JOIN ranks ON UPPER(ranks.name) = BTRIM(UPPER(#{TMP_TABLE}.accepted_rank))
            INNER JOIN taxon_concepts AS accepted
              ON accepted.legacy_id = #{TMP_TABLE}.accepted_legacy_id AND accepted.rank_id = ranks.id and accepted.legacy_type = '#{kingdom}'
            INNER JOIN ranks as synonyms_rank ON UPPER(synonyms_rank.name) = BTRIM(Upper(#{TMP_TABLE}.rank))
            INNER JOIN taxon_concepts AS synonym
              ON synonym.legacy_id = #{TMP_TABLE}.legacy_id AND synonym.rank_id = synonyms_rank.id and synonym.legacy_type = '#{kingdom}'
            LEFT JOIN taxonomies ON taxonomies.id = accepted.taxonomy_id AND taxonomies.id = synonym.taxonomy_id
            WHERE taxonomies.id = #{taxonomy.id}
              AND
                #{if taxonomy_name == Taxonomy::CITES_EU
                    "( UPPER(BTRIM(#{TMP_TABLE}.taxonomy)) like '%CITES%' OR UPPER(BTRIM(#{TMP_TABLE}.taxonomy)) like '%EU%')"
                  else
                    "UPPER(BTRIM(#{TMP_TABLE}.taxonomy)) like '%CMS%'"
                  end}

            EXCEPT

            SELECT taxon_concept_id, other_taxon_concept_id
            FROM taxon_relationships
            WHERE taxon_relationship_type_id = #{rel.id}

          ) q
        SQL
        ActiveRecord::Base.connection.execute(sql)
      end

      sql = <<-SQL
        UPDATE taxon_concepts
        SET full_name = full_name(ranks.name, ancestors_names(taxon_concepts.id))
        FROM taxon_concepts q
        JOIN ranks ON ranks.id = q.rank_id
        WHERE taxon_concepts.name_status = 'S'
          AND taxon_concepts.full_name IS NULL
          AND q.id = taxon_concepts.id
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end

    puts "There are now #{TaxonRelationship.
      joins(:taxon_relationship_type).
      where(
        "taxon_relationship_types.name" => TaxonRelationshipType::HAS_SYNONYM
      ).count} synonyms in the database."
  end

end
