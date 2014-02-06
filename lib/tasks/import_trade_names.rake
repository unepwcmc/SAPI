namespace :import do
  desc "Import names from csv file"
  task :trade_species_mapping => [:environment] do
    TMP_TABLE = "trade_species_mapping_import"
    file = "lib/files/trade_species_mapping_29114.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
  end

  desc "Import trade names from csv file"
  task :trade_names => [:environment] do
    TMP_TABLE = "trade_names_import"
    file = "lib/files/trade_names_to_add_8132.csv"

    taxonomy_id = Taxonomy.where(:name => 'CITES_EU').first.id
    taxon_relationship_type_id = TaxonRelationshipType.
      find_or_create_by_name(:name => TaxonRelationshipType::HAS_TRADE_NAME).id

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
        INNER JOIN ranks r ON trade_name_rank = r.name
        INNER JOIN taxon_names tn ON cites_trade_name = tn.scientific_name

        EXCEPT

        SELECT full_name, rank_id, taxon_name_id,
          legacy_trade_code,
          taxonomy_id, name_status
        FROM taxon_concepts
        WHERE taxon_concepts.taxonomy_id = #{taxonomy_id}
        AND name_status = 'T'

      ) AS subquery;

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
        LEFT JOIN taxon_concepts other_taxon_concepts
        ON cites_trade_name = other_taxon_concepts.full_name

        EXCEPT

        SELECT taxon_concept_id, other_taxon_concept_id,
          taxon_relationship_type_id
        FROM taxon_relationships
        WHERE taxon_relationship_type_id = #{taxon_relationship_type_id}
      ) AS subquery;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "There are #{TaxonConcept.where(:name_status => "T",
      :taxonomy_id => taxonomy_id).count} Trade Names in the database"
  end
end
