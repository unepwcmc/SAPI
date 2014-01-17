require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc "Import hybrids records from csv files (usage: rake import:hybrids[path/to/file,path/to/another])"
  task :hybrids, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'hybrids_import'
    taxonomy_id = Taxonomy.where(:name => 'CITES_EU').first.id
    taxon_relationship_id = TaxonRelationshipType.where(:name => 'HAS_HYBRID').first.id

    puts "There are #{TaxonConcept.where(:name_status => "H",
      :taxonomy_id => taxonomy_id).count} in the database"

      files = files_from_args(t, args)
      files.each do |file|
        drop_table(TMP_TABLE)
        create_table_from_csv_headers(file, TMP_TABLE)
        copy_data(file, TMP_TABLE)


        # Importing Hybrids, step by step:
        # TaxonConcepts  many to one relationship with taxon_names [scientific_name]
        # 1- Insert all scientific_names into taxon_names table (DISTINCT)
        # 2- Join back to insert the taxon_concepts
        # 3- Create taxon_relationships
        sql = <<-SQL

        INSERT INTO taxon_names(scientific_name, created_at, updated_at)
        SELECT DISTINCT full_hybrid_name,
        now()::date AS created_at,
        now()::date AS updated_at
        FROM hybrids_import;

        INSERT INTO taxon_concepts
        (full_name, 
        ranks_id, 
        taxon_names_id, 
        legacy_trade_code,
        taxonomy_id, 
        created_at, 
        updated_at)
        SELECT
        full_hybrid_name, 
        r.id as ranks_id, 
        tn.id as taxon_names_id, 
        legacy_cites_taxon_code as legacy_trade_code,
        #{taxonomy_id},
        now()::date AS created_at,
        now()::date AS updated_at
        FROM hybrids_import
        INNER JOIN ranks r ON hybrid_rank = r.name
        INNER JOIN taxon_names tn ON full_hybrid_name = tn.scientific_name;
        
        INSERT INTO taxon_relationships
        (taxon_concept_id,
        other_taxon_concept_id,
        taxon_relationship_id)
        SELECT 
        taxon_concepts.id,
        other_taxon_concepts.id,
        #{taxon_relationship_id}
        FROM hybrids_import hi
        INNER JOIN taxon_concepts
        ON species_plus_id = taxon_concepts.id;
        LEFT JOIN taxon_concepts other_taxon_concepts
        ON full_hybrid_name = other_taxon_concepts.full_name
        )
        SQL
        ActiveRecord::Base.connection.execute(sql)
        puts "There are now #{Quota.count} CITES quotas in the database"
      end
  end
end

