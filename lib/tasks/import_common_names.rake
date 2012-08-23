namespace :import do

  desc 'Import common names from SQL server [usage: rake import:common_names]'
  task :common_names => [:environment] do
    animals_query = <<-SQL
      Select ComRecID, C.ComName, L.LanDesc, S.SpcRecID
      from Orwell.animals.dbo.Species S 
      inner join Orwell.animals.dbo.CommonName C on C.ComSpcRecID = S.SpcRecID
      INNER JOIN ORWELL.animals.dbo.Language L ON L.LanRecID = C.ComLanRecID
      WHERE S.SpcRecID IN (#{TaxonConcept.where("legacy_type = 'animals' AND legacy_id IS NOT NULL").map(&:legacy_id).join(',')});
    SQL
    plants_query = <<-SQL
      Select ComRecID, C.ComName, L.LanDesc, S.SpcRecID
      from Orwell.plants.dbo.Species S 
      inner join Orwell.plants.dbo.CommonName C on C.ComSpcRecID = S.SpcRecID
      INNER JOIN ORWELL.plants.dbo.Language L ON L.LanRecID = C.ComLanRecID
      WHERE S.SpcRecID IN (#{TaxonConcept.where("legacy_type = 'plants' AND legacy_id IS NOT NULL").map(&:legacy_id).join(',')});
    SQL
    tmp_table = 'common_name_import'
    puts "There are #{CommonName.count} common names in the database."
    puts "There are #{TaxonCommon.count} taxon commons in the database."
    ["animals", "plants"].each do |t|
      drop_table(tmp_table)
      create_import_table(tmp_table)
      query = eval("#{t}_query")
      copy_data(tmp_table, query)
      sql = <<-SQL
        INSERT INTO common_names(name, language_id, created_at, updated_at)
        SELECT common_name, languages.id, current_date, current_date
          FROM #{tmp_table}
          LEFT JOIN languages ON #{tmp_table}.language_name = languages.name
          WHERE NOT EXISTS (
            SELECT common_names.name
              FROM common_names
              LEFT JOIN languages ON common_names.language_id = languages.id
              WHERE common_names.name = #{tmp_table}.common_name AND #{tmp_table}.language_name = languages.name
          );
  
        INSERT INTO taxon_commons(taxon_concept_id, common_name_id, created_at, updated_at)
        SELECT DISTINCT species.id, common_names.id, current_date, current_date
          FROM #{tmp_table}
          LEFT JOIN common_names ON #{tmp_table}.common_name = common_names.name
          LEFT JOIN languages ON #{tmp_table}.language_name = languages.name
          LEFT JOIN taxon_concepts as species ON species.legacy_id = species_id
          WHERE Species.id IS NOT NULL
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{CommonName.count} common names in the database"
    puts "There are #{TaxonCommon.count} taxon commons in the database."
  end

end
