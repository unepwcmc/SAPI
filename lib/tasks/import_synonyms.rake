namespace :import do
  desc 'Import synonyms from csv file (usage: rake import:synonyms[path/to/file,path/to/another])'
  task :synonyms, 10.times.map { |i| :"file_#{i}" } => [ :environment ] do |t, args|
    import_helper = CsvImportHelper.new

    TMP_TABLE = 'synonym_import'
    files = import_helper.files_from_args(t, args)

    ApplicationRecord.transaction do
      relationships = TaxonRelationship.joins(
        :taxon_relationship_type
      ).where(
        'taxon_relationship_types.name' => TaxonRelationshipType::HAS_SYNONYM
      )

      Rails.logger.debug do
        "There are #{relationships.count} synonyms in the database."
      end

      rel = TaxonRelationshipType.find_by(
        name: TaxonRelationshipType::HAS_SYNONYM
      )

      files.each do |file|
        import_helper.drop_table(TMP_TABLE)
        import_helper.create_table_from_csv_headers(file, TMP_TABLE)
        import_helper.copy_data(file, TMP_TABLE)

        kingdom = file.split('/').last.split('_')[0].titleize

        TaxonImportHelper.import_data_for_all_ranks(TMP_TABLE, kingdom, true)

        [ Taxonomy::CITES_EU, Taxonomy::CMS ].each do |taxonomy_name|
          Rails.logger.debug { "Import #{taxonomy_name} taxa" }

          taxonomy = Taxonomy.find_by(name: taxonomy_name)

          sql = <<-SQL.squish
            INSERT INTO taxon_relationships(
              taxon_relationship_type_id,
              taxon_concept_id, other_taxon_concept_id,
              created_at, updated_at
            )
            SELECT DISTINCT #{rel.id}, accepted_id, synonym_id, current_date, current_date
            FROM (
              SELECT accepted.id AS accepted_id, synonym.id AS synonym_id
              FROM #{TMP_TABLE}
              INNER JOIN ranks ON UPPER(ranks.name) = BTRIM(UPPER(#{TMP_TABLE}.accepted_rank))
              INNER JOIN taxon_concepts AS accepted
                ON accepted.id = #{TMP_TABLE}.accepted_id AND accepted.rank_id = ranks.id AND (accepted.legacy_type = '#{kingdom}' OR accepted.legacy_type IS NULL)
              INNER JOIN ranks as synonyms_rank ON UPPER(synonyms_rank.name) = BTRIM(Upper(#{TMP_TABLE}.rank))
              INNER JOIN taxon_concepts AS synonym
                ON synonym.author_year = BTRIM(#{TMP_TABLE}.author) AND synonym.parent_id = #{TMP_TABLE}.parent_id AND synonym.data->'accepted_id' = #{TMP_TABLE}.accepted_id::VARCHAR AND synonym.rank_id = synonyms_rank.id AND synonym.legacy_type = '#{kingdom}'
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

          ApplicationRecord.connection.execute(sql)
        end

        sql = <<-SQL.squish
          UPDATE taxon_concepts
          SET full_name = full_name(ranks.name, ancestors_names(taxon_concepts.id))
          FROM taxon_concepts q
          JOIN ranks ON ranks.id = q.rank_id
          WHERE taxon_concepts.name_status = 'S'
            AND taxon_concepts.full_name IS NULL
            AND q.id = taxon_concepts.id
        SQL

        ApplicationRecord.connection.execute(sql)
      end

      Rails.logger.debug do
        "There are now #{relationships.count} synonyms in the database."
      end
    end
  end
end
