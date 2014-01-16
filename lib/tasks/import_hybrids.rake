require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc "Import hybrids records from csv files (usage: rake import:hybrids[path/to/file,path/to/another])"
  task :hybrids, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'hybrids_import'
    taxonomy_id = Taxonomy.where(:name => 'CITES_EU').first.id

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
        SELECT full_hybrid_name,
        now()::date AS created_at,
        now()::date AS updated_at
        FROM hybrids_import;

        INSERT INTO taxon_concepts
        (name, 
          ranks_id, 
          taxon_names_id, 
          legacy_trade_code, 
          created_at, 
          updated_at)
        SELECT
        full_hybrid_name, 
        r.id as ranks_id, 
        tn.id as taxon_names_id, 
        legacy_cites_taxon_code as legacy_trade_code,
        tx.id,
        now()::date AS created_at,
        now()::date AS updated_at
        FROM hybrids_import
        INNER JOIN ranks r ON hybrid_rank = r.name
        INNER JOIN taxon_names tn ON full_hybrid_name = tn.scientific_name,
        taxonomies tx 
        WHERE tx.name = 'CITES_EU'
        SQL

        ActiveRecord::Base.connection.execute(sql)
        puts "There are now #{Quota.count} CITES quotas in the database"
      end
  end
end

