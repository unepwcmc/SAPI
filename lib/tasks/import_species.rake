namespace :import do

  desc "Import species records from csv file [usage: FILE=[path/to/file] rake import:species"
  task :species => [:environment, "species:copy_data"] do
    TMP_TABLE = 'species_import'
    import_data_for Rank::KINGDOM
    import_data_for Rank::PHYLUM, Rank::KINGDOM
    import_data_for Rank::CLASS, Rank::PHYLUM
    import_data_for Rank::ORDER, Rank::CLASS, 'TaxonOrder'
    import_data_for Rank::FAMILY, 'TaxonOrder'
    import_data_for Rank::GENUS, Rank::FAMILY
    import_data_for Rank::SPECIES, Rank::GENUS
    #rebuild the tree
    TaxonConcept.rebuild!
    #set the depth on all nodes
    TaxonConcept.roots.each do |root|
      TaxonConcept.each_with_level(root.self_and_descendants) do |node, level|
        node.send(:"set_depth!")
      end
    end
  end

  namespace :species do
    desc 'Creates species_import table'
    task :create_table => :environment do
      TMP_TABLE = 'species_import'
      begin
        puts "Creating tmp table"
        ActiveRecord::Base.connection.execute "CREATE TABLE #{TMP_TABLE} ( Kingdom varchar, Phylum varchar, Class varchar, TaxonOrder varchar, Family varchar, Genus varchar, Species varchar, SpcInfra varchar, SpcRecId integer, SpcStatus varchar)"
        puts "Table created"
      rescue Exception => e
        puts "Tmp already exists removing data from tmp table before starting the import"
        ActiveRecord::Base.connection.execute "DELETE FROM #{TMP_TABLE};"
        puts "Data removed"
      end
    end
    desc 'Copy data into species_import table'
    task :copy_data => :create_table do
      TMP_TABLE = 'species_import'
      file= ENV["FILE"] || 'lib/assets/files/animals.csv'
      if !file || !File.file?(Rails.root+file) #if the file is not defined, explain and leave.
        puts "Please specify a valid csv file from which to import species data"
        puts "Usage: FILE=[path/to/file] rake import:species"
        next
      end
      puts "Copying data from #{file} into tmp table #{TMP_TABLE}"
      psql = <<-PSQL
\\COPY #{TMP_TABLE} ( Kingdom, Phylum, Class, TaxonOrder, Family, Genus, Species, SpcInfra, SpcRecId, SpcStatus)
        FROM '#{Rails.root + file}'
        WITH DElIMITER ','
        CSV HEADER
      PSQL
      db_conf = YAML.load(File.open(Rails.root + "config/database.yml"))[Rails.env]
      system("export PGPASSWORD=#{db_conf["password"]} && psql -h #{db_conf["host"] || "localhost"} -U#{db_conf["username"]} -c \"#{psql}\" #{db_conf["database"]}")
      puts "Data copied to tmp table"
    end
    desc 'Removes species_import table'
    task :remove_table => :environment do
      TMP_TABLE = 'species_import'
      begin
        ActiveRecord::Base.connection.execute "DROP TABLE #{TMP_TABLE};"
        puts "Table removed"
      rescue Exception => e
        puts "Could not drop table #{TMP_TABLE}. It might not exist if this is the first time you are running this rake task."
      end
    end
  end
end

# Copies data from the temporary table to the correct tables in the database
#
# @param [String] which the column to be copied. It's normally the name of the rank being copied
# @param [String] parent_column to keep the hierarchy of the taxons the parent column should be passed
# @param [String] column_name if the which object is different from the column name in the tmp table, specify the column name
def import_data_for which, parent_column=nil, column_name=nil
  column_name ||= which
  puts "Importing #{which} from #{column_name}"
  rank_id = Rank.select(:id).where(:name => which).first.id
  existing = TaxonConcept.where(:rank_id => rank_id).count
  puts "There were #{existing} #{which} before we started"

  sql = <<-SQL
    INSERT INTO taxon_names(scientific_name, created_at, updated_at)
      SELECT DISTINCT INITCAP(BTRIM(#{column_name})), current_date, current_date
      FROM #{TMP_TABLE}
      WHERE NOT EXISTS (
        SELECT scientific_name
        FROM taxon_names
        WHERE INITCAP(scientific_name) LIKE INITCAP(BTRIM(#{TMP_TABLE}.#{column_name}))
      )
  SQL
  ActiveRecord::Base.connection.execute(sql)

  cites = Designation.find_by_name(Designation::CITES)
  if parent_column
    sql = <<-SQL
      INSERT INTO taxon_concepts(taxon_name_id, rank_id, designation_id, parent_id, created_at, updated_at #{if which == Rank::SPECIES then ', legacy_id' end})
         SELECT
           tmp.taxon_name_id
           ,#{rank_id}
           ,tmp.designation_id
           ,taxon_concepts.id
           ,current_date
           ,current_date
           #{ if which == Rank::SPECIES then ',tmp.spcrecid' end}
         FROM
          (
            SELECT DISTINCT taxon_names.id AS taxon_name_id, #{TMP_TABLE}.#{parent_column}, #{cites.id} AS designation_id #{if which == Rank::SPECIES then ", #{TMP_TABLE}.spcrecid" end}
            FROM #{TMP_TABLE}
            LEFT JOIN taxon_names ON (INITCAP(BTRIM(#{TMP_TABLE}.#{column_name})) LIKE INITCAP(BTRIM(taxon_names.scientific_name)))
            WHERE NOT EXISTS (
              SELECT taxon_name_id, rank_id
              FROM taxon_concepts
              WHERE taxon_concepts.taxon_name_id = taxon_names.id and taxon_concepts.rank_id = #{rank_id} )
          ) as tmp
          LEFT JOIN taxon_names ON (INITCAP(BTRIM(taxon_names.scientific_name)) LIKE INITCAP(BTRIM(tmp.#{parent_column})))
          LEFT JOIN taxon_concepts ON (taxon_concepts.taxon_name_id = taxon_names.id)
      RETURNING id;
    SQL
  else
    sql = <<-SQL
      INSERT INTO taxon_concepts(taxon_name_id, rank_id, designation_id, created_at, updated_at)
        SELECT DISTINCT taxon_names.id, #{rank_id}, #{cites.id} AS designation_id, current_date, current_date
        FROM #{TMP_TABLE} LEFT JOIN taxon_names ON (INITCAP(BTRIM(#{TMP_TABLE}.#{column_name})) LIKE INITCAP(BTRIM(taxon_names.scientific_name)))
        WHERE NOT EXISTS (
          SELECT taxon_name_id, rank_id
          FROM taxon_concepts
          WHERE taxon_name_id = taxon_names.id AND rank_id = #{rank_id}
        )
      RETURNING id;
    SQL
  end
  ActiveRecord::Base.connection.execute(sql)
  puts "#{TaxonConcept.where(:rank_id => rank_id).count - existing} #{which} added"
end
