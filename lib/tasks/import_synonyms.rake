namespace :import do

  desc 'Import synonyms from SQL Server [usage: rake import:synonyms]'
  task :synonyms => [:environment] do
    animals_query = <<-SQL
      Select 'Animalia' as Kingdom , P.PhyName, C.ClaName, O.OrdName, F.FamName, G.GenName, S.SpcName, S.SpcInfraEpithet, S.SpcRecID AS SynonymSpcRecID, S.SpcStatus, SynSpcRecID AS AcceptedSpcRecID
      from Orwell.animals.dbo.Species S 
      INNER JOIN ORWELL.animals.dbo.Genus G on S.Spcgenrecid = G.genrecid
      INNER JOIN ORWELL.animals.dbo.Family F ON FamRecID = GenFamRecID
      INNER JOIN ORWELL.animals.dbo.TaxOrder O ON OrdRecID = FamOrdRecID
      INNER JOIN ORWELL.animals.dbo.TaxClass C ON ClaRecID = OrdClaRecID
      INNER JOIN ORWELL.animals.dbo.TaxPhylum P ON PhyRecID = ClaPhyRecID
      INNER JOIN ORWELL.animals.dbo.SynLink Syn ON SynParentRecID = S.SpcRecID
      WHERE SynSpcRecID IN (#{TaxonConcept.where("legacy_type = 'animals' AND legacy_id IS NOT NULL").map(&:legacy_id).join(',')});
    SQL
    plants_query = <<-SQL
      Select 'Plantae' as Kingdom, O.OrdName, F.FamName, G.GenName, S.SpcName, S.SpcInfraEpithet, S.SpcRecID AS SynonymSpcRecID, S.SpcStatus, SynSpcRecID AS AcceptedSpcRecID
      from Orwell.plants.dbo.Species S 
      INNER JOIN ORWELL.plants.dbo.Genus G on S.Spcgenrecid = G.genrecid
      INNER JOIN ORWELL.plants.dbo.Family F ON FamRecID = GenFamRecID
      INNER JOIN ORWELL.plants.dbo.TaxOrder O ON OrdRecID = FamOrdRecID
      INNER JOIN ORWELL.plants.dbo.SynLink Syn ON SynParentRecID = S.SpcRecID
      WHERE SynSpcRecID IN (#{TaxonConcept.where("legacy_type = 'plants' AND legacy_id IS NOT NULL").map(&:legacy_id).join(',')});
    SQL
    puts "There are #{
      TaxonRelationship.
      joins(:taxon_relationship_type).
      where(
        "taxon_relationship_types.name" => TaxonRelationshipType::HAS_SYNONYM
      ).count
    } synonyms in the database."

    rel = TaxonRelationshipType.
      find_by_name(TaxonRelationshipType::HAS_SYNONYM)
    ["animals", "plants"].each do |t|
      tmp_table = "#{t}_synonym_import"
      drop_table(tmp_table)
      create_import_table(tmp_table)
      query = eval("#{t}_query")
      copy_data(tmp_table, query)

      #[BEGIN]copied over from import:species
      tmp_columns = MAPPING[tmp_table][:tmp_columns]
      import_data_for tmp_table, t, Rank::KINGDOM if tmp_columns.include? Rank::KINGDOM.capitalize
      if tmp_columns.include?(Rank::PHYLUM.capitalize) && 
        tmp_columns.include?(Rank::CLASS.capitalize) &&
        tmp_columns.include?('TaxonOrder')
        import_data_for tmp_table, t, Rank::PHYLUM, Rank::KINGDOM
        import_data_for tmp_table, t, Rank::CLASS, Rank::PHYLUM
        import_data_for tmp_table, t, Rank::ORDER, Rank::CLASS, 'TaxonOrder'
      elsif tmp_columns.include?(Rank::CLASS.capitalize) && tmp_columns.include?('TaxonOrder')
        import_data_for tmp_table, t, Rank::CLASS, Rank::KINGDOM
        import_data_for tmp_table, t, Rank::ORDER, Rank::CLASS, 'TaxonOrder'
      elsif tmp_columns.include? 'TaxonOrder'
        import_data_for tmp_table, t, Rank::ORDER, Rank::KINGDOM, 'TaxonOrder'
      end
      import_data_for tmp_table, t, Rank::FAMILY, 'TaxonOrder', nil, Rank::ORDER
      import_data_for tmp_table, t, Rank::GENUS, Rank::FAMILY
      import_data_for tmp_table, t, Rank::SPECIES, Rank::GENUS
      import_data_for tmp_table, t, Rank::SUBSPECIES, Rank::SPECIES, 'SpcInfra'
      #[END]copied over from import:species

      sql = <<-SQL
        INSERT INTO taxon_relationships(taxon_relationship_type_id,
          taxon_concept_id, other_taxon_concept_id,
          created_at, updated_at)
        SELECT #{rel.id}, accepted_id, synonym_id, current_date, current_date
        FROM (
          SELECT accepted.id AS accepted_id, synonym.id AS synonym_id
          FROM #{tmp_table}
          INNER JOIN taxon_concepts AS accepted
            ON accepted.legacy_id = #{tmp_table}.accepted_species_id
          INNER JOIN taxon_concepts AS synonym
            ON synonym.legacy_id = #{tmp_table}.SpcRecId
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
