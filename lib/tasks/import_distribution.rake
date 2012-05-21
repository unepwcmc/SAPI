namespace :import do

  desc 'Import distribution from csv file [usage: FILE=[path/to/file] rake import:distribution'
  task :distribution => :environment do
    TMP_TABLE = 'distribution_import'
    if !ENV["FILE"] || !File.file?(Rails.root+ENV["FILE"]) #if the file is not defined, explain and leave.
      puts "Please specify a valid csv file for the distribution from which to import distribution data"
      puts "Usage: FILE=[path/to/file] rake import:distribution"
      next
    end
    begin
      puts "Creating tmp table: #{TMP_TABLE}"
      ActiveRecord::Base.connection.execute "CREATE TABLE #{TMP_TABLE} ( species_id integer, country_id integer, country_name varchar);"
      puts "Table created"
    rescue Exception => e
      puts "Tmp already exists removing data from tmp table before starting the import"
      ActiveRecord::Base.connection.execute "DELETE FROM #{TMP_TABLE};"
      puts "Data removed"
    end
    puts "Copying data from #{ENV["FILE"]} into tmp table"
    sql = <<-SQL
      COPY #{TMP_TABLE} (species_id, country_id, country_name)
      FROM '#{Rails.root + ENV["FILE"]}'
      WITH DElIMITER ','
      CSV HEADER;
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "Data copied to tmp table"
    puts "There are #{Distribution.count} distributions in the database."
    sql = <<-SQL
      INSERT INTO distributions(taxon_concept_id, created_at, updated_at)
      SELECT DISTINCT taxon_concepts.id, current_date, current_date
        FROM 
          public.taxon_concepts, 
          public.distribution_import
          WHERE 
            distribution_import.species_id = taxon_concepts.legacy_id
          AND NOT EXISTS (
            SELECT id from distributions
            WHERE taxon_concept_id = taxon_concepts.id
          );
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "There are now #{Distribution.count} distributions in the database"
    puts "Added distribution, going to add distribution components"
    puts "There are #{DistributionComponent.count} distributions components in the database."
    sql = <<-SQL
      INSERT INTO distribution_components(distribution_id, component_id, component_type, created_at, updated_at)
      SELECT DISTINCT distributions.id, countries.id, 'Country', current_date, current_date
        FROM #{TMP_TABLE}
        LEFT JOIN countries ON countries.legacy_id = country_id
        LEFT JOIN taxon_concepts as species ON species.legacy_id = species_id
        LEFT JOIN distributions ON distributions.taxon_concept_id = species.id
    SQL
    ActiveRecord::Base.connection.execute(sql)
    puts "There are now #{DistributionComponent.count} distributions components in the database"
  end


  namespace :distribution do
    desc 'Removes distribution_import table'
    task :remove_table => :environment do
      TMP_TABLE = 'distribution_import'
      begin
        ActiveRecord::Base.connection.execute "DROP TABLE #{TMP_TABLE};"
        puts "Table removed"
      rescue Exception => e
        puts e.message
        puts "Could not drop table #{TMP_TABLE}. It might not exist if this is the first time you are running this rake task."
      end
    end
  end
end

