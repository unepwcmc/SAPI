namespace :import do

  desc 'Import distributions from SQL Server [usage: rake import:distributions]'
  task :distributions => [:environment] do
    animals_query = <<-SQL
      Select DctRecID, S.SpcRecID, Cty.CtyRecID, Cty.CtyShort
      from ORWELL.animals.dbo.Species S 
      INNER JOIN ORWELL.animals.dbo.DistribCty Dcty ON S.SpcRecID = Dcty.DCtSpcRecID
      INNER JOIN ORWELL.animals.dbo.Country Cty ON Dcty.DCtCtyRecID = Cty.CtyRecID
      WHERE S.SpcRecID IN (#{TaxonConcept.where("legacy_type = 'animals' AND legacy_id IS NOT NULL").limit(2000).map(&:legacy_id).join(',')});
    SQL
    plants_query = <<-SQL
      Select DctRecID, S.SpcRecID, Cty.CtyRecID, Cty.CtyShort
      from ORWELL.plants.dbo.Species S 
      INNER JOIN ORWELL.plants.dbo.DistribCty Dcty ON S.SpcRecID = Dcty.DCtSpcRecID
      INNER JOIN ORWELL.plants.dbo.Country Cty ON Dcty.DCtCtyRecID = Cty.CtyRecID
      WHERE S.SpcRecID IN (#{TaxonConcept.where("legacy_type = 'plants' AND legacy_id IS NOT NULL").limit(2000).map(&:legacy_id).join(',')});
    SQL
    tmp_table = 'distribution_import'
    ["animals", "plants"].each do |t|
      puts "There are #{TaxonConceptGeoEntity.count} taxon concept distributions in the database."
      drop_table(tmp_table)
      create_import_table(tmp_table)
      query = eval("#{t}_query")
      copy_data(tmp_table, query)
      sql = <<-SQL
        INSERT INTO taxon_concept_geo_entities(taxon_concept_id, geo_entity_id, created_at, updated_at)
        SELECT DISTINCT species.id, geo_entities.id, current_date, current_date
          FROM #{tmp_table}
          LEFT JOIN geo_entities ON geo_entities.legacy_id = country_id AND geo_entities.legacy_type = '#{GeoEntityType::COUNTRY}'
          LEFT JOIN taxon_concepts as species ON species.legacy_id = species_id
          WHERE Species.id IS NOT NULL AND geo_entities.id IS NOT NULL
      SQL
      #TODO do sth about those unknown distributions!
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{TaxonConceptGeoEntity.count} taxon concept distributions in the database"
  end

end

