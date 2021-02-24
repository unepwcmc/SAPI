namespace :import do
  desc "Import trade - species_plus mapping table from csv file"
  task :trade_species_mapping => [:environment] do
    TMP_TABLE = "trade_species_mapping_import"
    file = "lib/files/names_for_transfer_29116.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
  end

  desc "Import trade names (which didn't exist in SpeciesPlus) from csv file"
  task :trade_names => [:environment] do
    TMP_TABLE = "trade_names_import"
    file = "lib/files/trade_names_to_add_9513.csv"

    taxonomy_id = Taxonomy.where(:name => 'CITES_EU').first.id
    taxon_relationship_type_id = TaxonRelationshipType.
      find_or_create_by(:name => TaxonRelationshipType::HAS_TRADE_NAME).id

    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)

    puts "There are #{TaxonConcept.where(:name_status => "T",
      :taxonomy_id => taxonomy_id).count} Trade Names in the database"

    # Importing Trade Names, step by step:
    # TaxonConcepts  many to one relationship with taxon_names [scientific_name]
    # 1- Insert all scientific_names into taxon_names table (DISTINCT)
    # 2- Join back to insert the taxon_concepts
    # 3- Create taxon_relationships
    sql = <<-SQL
      INSERT INTO taxon_names(scientific_name, created_at, updated_at)
      SELECT subquery.*,
        now()::date AS created_at,
        now()::date AS created_at
      FROM (
        SELECT DISTINCT cites_trade_name
        FROM #{TMP_TABLE}

        EXCEPT

        SELECT scientific_name
        FROM taxon_names
      ) AS subquery;
    SQL
    puts "Inserting taxon names"
    ActiveRecord::Base.connection.execute(sql)

    sql = <<-SQL
      INSERT INTO taxon_concepts (full_name,
        rank_id,
        taxon_name_id,
        legacy_trade_code,
        taxonomy_id,
        name_status,
        created_at,
        updated_at)
      SELECT
        subquery.*,
        now()::date AS created_at,
        now()::date AS updated_at
      FROM (
        SELECT
          cites_trade_name,
          r.id as rank_id,
          tn.id as taxon_names_id,
          legacy_cites_taxon_code as legacy_trade_code,
          #{taxonomy_id}, 'T'
        FROM #{TMP_TABLE}
        INNER JOIN ranks r ON BTRIM(UPPER(trade_name_rank)) = BTRIM(UPPER(r.name))
        INNER JOIN taxon_names tn ON BTRIM(UPPER(cites_trade_name)) = BTRIM(UPPER(tn.scientific_name))

        EXCEPT

        SELECT full_name, rank_id, taxon_name_id,
          legacy_trade_code,
          taxonomy_id, name_status
        FROM taxon_concepts
        WHERE taxon_concepts.taxonomy_id = #{taxonomy_id}
        AND name_status = 'T'

      ) AS subquery;
    SQL
    puts "Inserting the trade names into taxon_concepts table"
    ActiveRecord::Base.connection.execute(sql)

    sql = <<-SQL
      INSERT INTO taxon_relationships
        (taxon_concept_id,
        other_taxon_concept_id,
        taxon_relationship_type_id,
        created_at,
        updated_at)
      SELECT
        subquery.*,
        now()::date AS created_at,
        now()::date AS updated_at
      FROM (
        SELECT
          taxon_concepts.id,
          other_taxon_concepts.id,
          #{taxon_relationship_type_id}
        FROM #{TMP_TABLE} hi
        INNER JOIN taxon_concepts
        ON valid_name_speciesplus_id = taxon_concepts.id
        INNER JOIN taxon_concepts other_taxon_concepts
        ON legacy_cites_taxon_code = other_taxon_concepts.legacy_trade_code

        EXCEPT

        SELECT taxon_concept_id, other_taxon_concept_id,
          taxon_relationship_type_id
        FROM taxon_relationships
        WHERE taxon_relationship_type_id = #{taxon_relationship_type_id}
      ) AS subquery;
    SQL
    puts "Inserting the taxon Relationships between taxon concepts and trade_names"
    ActiveRecord::Base.connection.execute(sql)
    puts "There are #{TaxonConcept.where(:name_status => "T",
      :taxonomy_id => taxonomy_id).count} Trade Names in the database"
  end

  desc "Change status of fake synonyms to be trade_names, update leaf nodes"
  task :synonyms_to_trade_names => [:environment] do
    TMP_TABLE = "synonyms_to_trade_mapping_import"
    file = "lib/files/synonyms_to_trade_names.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    Sapi::Indexes.drop_indexes_on_trade_names
    copy_data(file, TMP_TABLE)
    has_trade_name = TaxonRelationshipType.
      find_or_create_by(:name => TaxonRelationshipType::HAS_TRADE_NAME).id
    has_synonym = TaxonRelationshipType.
      find_or_create_by(:name => TaxonRelationshipType::HAS_SYNONYM).id
    count_trade_names = TaxonConcept.where(:name_status => 'T').count
    count_synonyms = TaxonConcept.where(:name_status => 'S').count
    count_taxon_names = TaxonName.count
    count_trade_relationships = TaxonRelationship.where(:taxon_relationship_type_id => has_trade_name).count
    count_synonym_relationships = TaxonRelationship.where(:taxon_relationship_type_id => has_synonym).count
    taxon_concept_ids = ActiveRecord::Base.connection.execute("SELECT cites_taxon_code, species_plus_id AS id FROM #{TMP_TABLE}").
      map { |h| [h["cites_taxon_code"], h["id"]] }
    taxon_concept_ids.each do |cites_code, id|
      tc = TaxonConcept.find id
      next if tc.name_status != "S"
      puts "Updating #{tc.full_name}"
      unless tc.accepted_names.any?
        puts "from synonym to trade_name"
        tc.update_attributes(:name_status => "T", :parent_id => nil,
                            :legacy_trade_code => cites_code)
      end
      puts "Update its children's taxon_name_id"
      tc.children.each do |child|
        if child.accepted_names.any?
          puts "looking at #{child.full_name} scientific_name"
          taxon_name = TaxonName.find_or_create_by(scientific_name: child.full_name)
          child.update_attributes(:parent_id => nil, :taxon_name_id => taxon_name.id)
        end
      end
    end
    TaxonName.joins('LEFT JOIN taxon_concepts ON taxon_name_id = taxon_names.id').
      where('taxon_concepts.id IS NULL').each do |t_name|
      unless TaxonConcept.where(:taxon_name_id => t_name.id).any?
        puts "deleting unnused taxon_name #{t_name.scientific_name}"
        t_name.delete
      end
    end
    puts "Create trade_names relationship"

    sql = <<-SQL
      INSERT INTO taxon_relationships(taxon_concept_id, other_taxon_concept_id, taxon_relationship_type_id,
        created_at, updated_at)
      SELECT subquery.*, current_date, current_date
      FROM (
        SELECT DISTINCT accepted_id, species_plus_id, #{has_trade_name}
        FROM #{TMP_TABLE}

        EXCEPT

        SELECT taxon_concept_id, other_taxon_concept_id, taxon_relationship_type_id
        FROM taxon_relationships
        WHERE taxon_relationship_type_id = #{has_trade_name}
      ) as subquery;

    SQL
    ActiveRecord::Base.connection.execute(sql)

    puts "Update trade_species_mapping_import table"
    sql = <<-SQL
      WITH new_mapping AS (
        SELECT cites_taxon_code, new_mapper.full_name, new_mapper.id FROM taxon_concepts
        INNER JOIN taxon_relationships ON other_taxon_concept_id = taxon_concepts.id
        AND taxon_relationship_type_id = #{has_trade_name} AND taxon_concepts.name_status = 'T'
        INNER JOIN trade_species_mapping_import ON species_plus_id = taxon_concepts.id
        AND cites_taxon_code <> taxon_concepts.legacy_trade_code
        INNER JOIN taxon_concepts AS new_mapper ON new_mapper.id = taxon_relationships.taxon_concept_id
      )
      UPDATE trade_species_mapping_import
      SET species_plus_name = new_mapping.full_name, species_plus_id = new_mapping.id
      FROM new_mapping
      WHERE trade_species_mapping_import.cites_taxon_code = new_mapping.cites_taxon_code;
    SQL
    ActiveRecord::Base.connection.execute(sql)

    final_count_trade_names = TaxonConcept.where(:name_status => 'T').count
    final_count_synonyms = TaxonConcept.where(:name_status => 'S').count
    final_count_taxon_names = TaxonName.count
    final_count_trade_relationships = TaxonRelationship.where(:taxon_relationship_type_id => has_trade_name).count
    final_count_synonym_relationships = TaxonRelationship.where(:taxon_relationship_type_id => has_synonym).count

    puts "############# SUMMARY ###################"
    puts "Pre-Existing trade_names: #{count_trade_names}; Final count trade_names: #{final_count_trade_names};\
      Diff: #{final_count_trade_names - count_trade_names}"
    puts "Pre-Existing synonyms: #{count_synonyms}; Final count synonyms: #{final_count_synonyms};\
      Diff: #{final_count_synonyms - count_synonyms}"
    puts "Pre-Existing taxon_names: #{count_taxon_names}; Final count taxon_names: #{final_count_taxon_names};\
      Diff: #{final_count_taxon_names - count_taxon_names}"
    puts "Pre-Existing trade_relationships: #{count_trade_relationships}; Final count trade_relationships: #{final_count_trade_relationships};\
      Diff: #{final_count_trade_relationships - count_trade_relationships}"
    puts "Pre-Existing synonym_relationships: #{count_synonym_relationships}; Final count synonym_relationships: #{final_count_synonym_relationships};\
      Diff: #{final_count_synonym_relationships - count_synonym_relationships}"
    Sapi::Indexes.create_indexes_on_trade_names
  end
end
