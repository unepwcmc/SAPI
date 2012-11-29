namespace :import do

  desc 'Import synonyms from csv file (usage: rake import:synonyms[path/to/file,path/to/another])'
  task :synonyms, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'synonym_import'
    puts "There are #{
      TaxonRelationship.
      joins(:taxon_relationship_type).
      where(
        "taxon_relationship_types.name" => TaxonRelationshipType::HAS_SYNONYM
      ).count
    } synonyms in the database."

    rel = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)

    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      #[BEGIN]copied over from import:species
      db_columns = db_columns_from_csv_headers(file, TMP_TABLE, false)
      import_data_for Rank::KINGDOM if db_columns.include? Rank::KINGDOM.capitalize
      if db_columns.include?(Rank::PHYLUM.capitalize) && 
        db_columns.include?(Rank::CLASS.capitalize) &&
        db_columns.include?('TaxonOrder')
        import_data_for Rank::PHYLUM, Rank::KINGDOM
        import_data_for Rank::CLASS, Rank::PHYLUM
        import_data_for Rank::ORDER, Rank::CLASS, 'TaxonOrder'
      elsif db_columns.include?(Rank::CLASS.capitalize) && db_columns.include?('TaxonOrder')
        import_data_for Rank::CLASS, Rank::KINGDOM
        import_data_for Rank::ORDER, Rank::CLASS, 'TaxonOrder'
      elsif db_columns.include? 'TaxonOrder'
        import_data_for Rank::ORDER, Rank::KINGDOM, 'TaxonOrder'
      end
      import_data_for Rank::FAMILY, 'TaxonOrder', nil, Rank::ORDER
      import_data_for Rank::GENUS, Rank::FAMILY
      import_data_for Rank::SPECIES, Rank::GENUS
      import_data_for Rank::SUBSPECIES, Rank::SPECIES, 'SpcInfra'
      #[END]copied over from import:species

      sql = <<-SQL
        INSERT INTO taxon_relationships(taxon_relationship_type_id,
          taxon_concept_id, other_taxon_concept_id,
          created_at, updated_at)
        SELECT #{rel.id}, accepted_id, synonym_id, current_date, current_date
        FROM (
          SELECT accepted.id AS accepted_id, synonym.id AS synonym_id
          FROM #{TMP_TABLE}
          INNER JOIN taxon_concepts AS accepted
            ON accepted.legacy_id = #{TMP_TABLE}.accepted_species_id
          INNER JOIN taxon_concepts AS synonym
            ON synonym.legacy_id = #{TMP_TABLE}.SpcRecId
          WHERE NOT EXISTS (
            SELECT * FROM taxon_relationships
            LEFT JOIN taxon_concepts AS accepted
            ON accepted.id = taxon_relationships.taxon_concept_id
            LEFT JOIN taxon_concepts AS synonym
            ON synonym.id = taxon_relationships.other_taxon_concept_id
            WHERE taxon_relationships.taxon_relationship_type_id = #{rel.id}
          )
        ) q
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end

    puts "There are now #{
      TaxonRelationship.
      joins(:taxon_relationship_type).
      where(
        "taxon_relationship_types.name" => TaxonRelationshipType::HAS_SYNONYM
      ).count
    } synonyms in the database."
  end

end
