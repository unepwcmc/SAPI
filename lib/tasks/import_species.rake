require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc "Import species records from csv files [usage: rake import:species[path/to/file,path/to/another]"
  task :species => [:environment] do
    animals_query = <<-SQL
      SELECT S.SpcRecID as SpcRecId, 'Animalia' as Kingdom, P.PhyName, C.ClaName, O.OrdName, F.FamName, G.GenName, S.SpcName, S.SpcInfraEpithet, S.SpcStatus
      FROM [Animals].[dbo].[Species] S
      inner join ORWELL.animals.dbo.Genus G on S.Spcgenrecid = G.genrecid
      INNER JOIN ORWELL.animals.dbo.Family F ON FamRecID = GenFamRecID
      INNER JOIN ORWELL.animals.dbo.TaxOrder O ON OrdRecID = FamOrdRecID
      INNER JOIN ORWELL.animals.dbo.TaxClass C ON ClaRecID = OrdClaRecID
      INNER JOIN ORWELL.animals.dbo.TaxPhylum P ON PhyRecID = ClaPhyRecID
      WHERE S.SpcStatus = 'A' AND C.ClaName IN ('Mammalia', 'Reptilia')
    SQL

    plants_query = <<-SQL
      Select S.SpcRecID as SpcRecId, 'Plantae' as Kingdom, O.OrdName, F.FamName, G.GenName, S.Spcname, S.SpcInfraepithet, S.SpcStatus
      from ORWELL.plants.dbo.Species S 
      inner join ORWELL.plants.dbo.Genus G on S.Spcgenrecid = G.genrecid
      INNER JOIN ORWELL.plants.dbo.Family F ON FamRecID = GenFamRecID
      INNER JOIN ORWELL.plants.dbo.TaxOrder O ON OrdRecID = FamOrdRecID
      WHERE S.SpcStatus = 'A' AND O.OrdName IN ('ALISMATALES', 'TYPHALES', 'JUNCALES', 'ARISTOLOCHIALES')
    SQL
    ["animals", "plants"].each do |t|
      puts "Importing #{t.capitalize}"
      tmp_table = "#{t}_import"
      drop_table(tmp_table)
      create_import_table(tmp_table)
      query = eval("#{t}_query")
      copy_data_in_batches(tmp_table, query, 'SpcRecId', 5000)
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
    end
    #rebuild the tree
    TaxonConcept.rebuild!
    #set the depth on all nodes
    TaxonConcept.roots.each do |root|
      TaxonConcept.each_with_level(root.self_and_descendants) do |node, level|
        node.send(:"set_depth!")
      end
    end
  end
end

# Copies data from the temporary table to the correct tables in the database
#
# @param [String] legacy_type either 'animals' or 'plants'
# @param [String] which the column to be copied. It's normally the name of the rank being copied
# @param [String] parent_column to keep the hierarchy of the taxons the parent column should be passed
# @param [String] column_name if the which object is different from the column name in the tmp table, specify the column name
# @param [String] parent_rank if the parent_column is different from the rank name, specify parent rank
def import_data_for tmp_table, legacy_type, which, parent_column=nil, column_name=nil, parent_rank=nil
  column_name ||= which
  puts "Importing #{which} from #{column_name} (#{parent_column})"
  rank_id = Rank.select(:id).where(:name => which).first.id
  parent_rank ||= parent_column
  parent_rank_id = ((r = Rank.select(:id).where(:name => parent_rank).first) && r.id || nil)
  existing = TaxonConcept.where(:rank_id => rank_id).count
  puts "There were #{existing} #{which} before we started"

  sql = <<-SQL
    INSERT INTO taxon_names(scientific_name, created_at, updated_at)
      SELECT DISTINCT INITCAP(BTRIM(#{column_name})), current_date, current_date
      FROM #{tmp_table}
      WHERE NOT EXISTS (
        SELECT scientific_name
        FROM taxon_names
        WHERE INITCAP(scientific_name) LIKE INITCAP(BTRIM(#{tmp_table}.#{column_name}))
      ) AND BTRIM(#{column_name}) <> 'NULL'
  SQL
  ActiveRecord::Base.connection.execute(sql)

  cites = Designation.find_by_name(Designation::CITES)
  if parent_column
    sql = <<-SQL
      INSERT INTO taxon_concepts(taxon_name_id, rank_id, designation_id,
      parent_id, created_at, updated_at, legacy_type #{if [Rank::SPECIES, Rank::SUBSPECIES].include? which then ', legacy_id' end})
         SELECT
           tmp.taxon_name_id
           ,#{rank_id}
           ,tmp.designation_id
           ,taxon_concepts.id
           ,current_date
           ,current_date
           ,'#{legacy_type}'
           #{ if [Rank::SPECIES, Rank::SUBSPECIES].include? which then ', tmp.spcrecid'end}
         FROM
          (
            SELECT DISTINCT taxon_names.id AS taxon_name_id,
           #{tmp_table}.#{parent_column}, #{cites.id} AS designation_id
           #{if [Rank::SPECIES, Rank::SUBSPECIES].include? which then ", #{tmp_table}.spcrecid" end}
            FROM #{tmp_table}
            LEFT JOIN taxon_names ON (INITCAP(BTRIM(#{tmp_table}.#{column_name})) LIKE INITCAP(BTRIM(taxon_names.scientific_name)))
            WHERE NOT EXISTS (
              SELECT taxon_name_id, rank_id, designation_id
              FROM taxon_concepts
              WHERE taxon_concepts.taxon_name_id = taxon_names.id AND
                taxon_concepts.rank_id = #{rank_id} AND
                taxon_concepts.designation_id = #{cites.id}
            )
            AND taxon_names.id IS NOT NULL
                #{
                if which == Rank::SPECIES then " AND (BTRIM(#{tmp_table}.SpcInfra) IS NULL OR BTRIM(#{tmp_table}.SpcInfra) = '' )"
                elsif which == Rank::SUBSPECIES then " AND (BTRIM(#{tmp_table}.SpcInfra) IS NOT NULL OR BTRIM(#{tmp_table}.SpcInfra) <> '')"
                end
                }
          ) as tmp
          LEFT JOIN taxon_names ON (INITCAP(BTRIM(taxon_names.scientific_name)) LIKE INITCAP(BTRIM(tmp.#{parent_column})))
          LEFT JOIN taxon_concepts ON (
            taxon_concepts.taxon_name_id = taxon_names.id
            AND taxon_concepts.rank_id = #{parent_rank_id}
          )
      RETURNING id;
    SQL
  else
    sql = <<-SQL
      INSERT INTO taxon_concepts(taxon_name_id, rank_id, designation_id, created_at, updated_at)
        SELECT DISTINCT taxon_names.id, #{rank_id}, #{cites.id} AS designation_id, current_date, current_date
        FROM #{tmp_table} LEFT JOIN taxon_names ON (INITCAP(BTRIM(#{tmp_table}.#{column_name})) LIKE INITCAP(BTRIM(taxon_names.scientific_name)))
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
