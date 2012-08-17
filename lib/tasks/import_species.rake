require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc "Import species records from csv files [usage: rake import:species[path/to/file,path/to/another]"
  task :species => [:environment] do
    animals_query = <<-SQL
      SELECT 'Animalia' as Kingdom, P.PhyName, C.ClaName, O.OrdName, F.FamName, G.GenName, S.SpcName, S.SpcInfraEpithet, S.SpcRecID, S.SpcStatus
      FROM [Animals].[dbo].[Species] S
      inner join ORWELL.animals.dbo.Genus G on S.Spcgenrecid = G.genrecid
      INNER JOIN ORWELL.animals.dbo.Family F ON FamRecID = GenFamRecID
      INNER JOIN ORWELL.animals.dbo.TaxOrder O ON OrdRecID = FamOrdRecID
      INNER JOIN ORWELL.animals.dbo.TaxClass C ON ClaRecID = OrdClaRecID
      INNER JOIN ORWELL.animals.dbo.TaxPhylum P ON PhyRecID = ClaPhyRecID
      WHERE S.SpcStatus = 'A' AND S.SpcRecID IN (
        90, 98, 129, 130, 219, 222, 223, 226, 230, 512, 660, 661, 662, 663, 664, 665,
        666, 667, 668, 679, 681, 682, 699, 702, 712, 845, 846, 847, 848, 849, 866, 867,
        901, 981, 983, 1041, 1043, 1044, 1046, 1047, 1051, 1052, 1053, 105354, 1057, 1059,
        1060, 1061, 1064, 1065, 1068, 1070, 1071, 1072, 1073,   1084, 1086, 1151, 1217, 1219,
        1223, 1224, 1225, 1231, 1233, 1548, 1549, 1550, 1551, 1572, 1681, 1793, 1820, 1931,
        1932, 1951, 1953, 1956, 195663, 1967, 1968, 1969, 1974, 1992, 1993, 1994, 1995, 1996,
        1997, 1998,   1999, 2000, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011,
        2015, 2024, 2051, 2074, 2173, 2266, 2370, 2457, 2464, 2467, 2474, 2475, 2475476, 2477,
        2478, 2480, 2609, 2613, 2614, 2678, 2763, 2813, 2836, 2852, 2853, 2854, 2855,
        2856, 2897, 2899, 2916, 2918, 2919, 2920, 29201, 2977, 3058, 3112, 3113, 3114, 3115,
        3116, 3117, 3118, 3119, 3124, 3124125, 3133, 3145, 3160, 3171, 3335, 3340, 3345, 3347,
        3352, 3356, 3360, 3360, 3362, 3370, 3373, 3374, 3375, 3376, 3412, 3414, 3423, 3424, 3425,
        34256, 3427, 3428, 3429, 3430, 3431, 3432, 3433, 3449, 3453, 3454, 3455, 3456, 3457,
        3459, 3586, 3607, 3625, 3657, 3658, 3659, 3661, 3742, 3744, 3744746, 3749, 3750, 3778,
        3847, 3855, 3897, 4000, 4015, 4139, 4140, 4148,4148, 4150, 4153, 4157, 4158, 4189, 4222,
        4225, 4232, 4259, 4292, 1224, 12245, 1231, 1233, 1548, 1549, 1550, 1551, 1572, 1681, 1793, 18573,
        1997, 1998, 1999, 2000, 2002, 2003, 2004, 2005,4780,
        4781, 4798, 4903, 4940, 4962, 4967, 4996, 5144, 5146, 5152, 5153, 5154, 5155, 5156,
        515657, 5158, 5159, 5160, 5161, 5162, 5163, 5164, 5165, 5187, 5189, 5191, 5192, 5202,
        5321, 5322, 5361, 5415, 5503, 5506, 5503, 2614, 2678, 2763, 2763,
        2856, 5670, 5671, 5684, 56845, 5792, 5984, 5985, 5993, 6003, 6021,
        6023, 6235, 6277, 6336, 6358, 6358359, 6360, 54, 55, 56, 88, 89, 91, 92, 93, 94, 96, 97,
        99, 101, 102, 10203, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117,
        118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 131, 132, 133, 1334, 136, 137, 138,
        139, 140, 142, 144, 145, 146, 147, 148, 149, 150, 1501, 152, 153, 154, 156, 157, 158, 159,
        160, 167, 168, 169, 170, 171, 1712, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183,
        184, 185, 1856, 188, 189, 190, 191, 192, 193, 194, 195, 197, 198, 199, 200, 201, 202, 203,
        204, 205, 207, 209, 224, 225, 227, 228, 229, 231, 232, 233, 234, 2345, 236, 241, 244, 282,
        283, 285, 316, 318, 319, 320, 323, 325, 327, 3278, 329, 330, 333, 334, 335, 336, 337, 339,
        340, 341, 344, 345, 348, 3489, 351, 353, 355, 356, 358, 360, 362, 363, 364, 365, 366, 367,
        368, 37781, 372, 373, 375, 376, 377, 380, 381, 382, 383, 384, 385, 386, 387, 388, 390, 391,
        392, 393, 394, 395, 396, 397, 398, 399, 400, 403, 404, 405,   406, 407, 409, 413, 415, 416,
        417, 418, 420, 423, 424, 425, 426, 427,   429, 430, 431, 432, 433, 434, 437, 439, 440, 442,
        443, 445, 446, 447,   450, 455, 458, 459, 460, 461, 462, 463, 464, 467, 468, 469, 470, 471,
        472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 484, 485, 486, 487, 488, 489, 490, 491,
        514, 516, 517, 518, 519, 535, 536, 537, 538, 544, 670, 671, 672, 673, 674, 675, 676, 687,
        688, 689, 690, 691, 692, 714, 782, 865, 868, 878, 909, 910, 911, 912, 913, 914, 915, 916,
        960, 961, 962, 963, 965, 966, 967, 968, 969, 971, 973, 974, 975, 982, 1011,1011,
        1015, 1016, 1017, 1018, 1019, 1020, 1021, 1024, 10245, 1026, 1027, 1028, 1029, 1030, 1031, 1032,
        1033, 1034, 1035, 1036, 1036037, 1038, 1039, 1040, 1042, 1045, 1048, 1049, 1050, 1055, 1056, 1058,
        1062, 1063, 1066, 1067, 1069, 1077, 1092, 1093, 1095, 1181, 1184, 1192, 1194,   1195, 1196, 1197,
        1221, 1222, 1228, 1229, 1230, 1238, 1239, 125, 39798, 399, 400, 403, 404, 405, 406, 407, 409);
    SQL

    plants_query = <<-SQL
      Select 'Plantae' as Kingdom, O.OrdName, F.FamName, G.GenName, S.Spcname, S.SpcInfraepithet, S.SpcRecID, S.SpcStatus
      from ORWELL.plants.dbo.Species S 
      inner join ORWELL.plants.dbo.Genus G on S.Spcgenrecid = G.genrecid
      INNER JOIN ORWELL.plants.dbo.Family F ON FamRecID = GenFamRecID
      INNER JOIN ORWELL.plants.dbo.TaxOrder O ON OrdRecID = FamOrdRecID
      WHERE S.SpcStatus = 'A' AND S.SpcRecID IN (2220, 5114, 8039, 8277, 8359, 8843, 9200, 9258, 9314, 10365, 10723, 10958, 
      11667, 11913, 11976, 12320, 12379, 12445, 12445, 12509, 12946, 13728, 14505, 
      14559, 15071, 15637, 15692, 15751, 16280, 16337, 16759, 16823, 17178, 17781, 
      17845, 17906, 17906, 17967, 18038, 18173, 19362, 20903, 20961, 21018, 21191,
      22181, 24285, 24473, 26422, 27596, 27650, 27767, 49776, 49842, 49904, 49960, 
      50021, 50463, 50530, 50597, 50728, 50796, 51461, 51809, 52006, 52068, 52130, 
      52399, 53486, 53969, 54406, 54889, 56014, 58390, 58673, 58735, 84809, 87333, 
      88022, 88101, 88419, 88637, 100018, 100452, 100604, 100759, 101652, 102460, 
      104810, 104952, 105235, 28387, 28445, 28616, 29390, 29500, 29559, 29614, 30065, 
      30246, 30306, 30423, 30490, 30558, 31399, 31597, 32554, 35862, 36458, 40234, 
      40909, 41149, 41675, 43085, 43219, 43612, 43829, 44309, 44568, 44759, 45194, 
      132028, 60818, 61193, 61193, 61711, 62284, 62600, 63003, 67745, 68437, 69017, 
      69097, 70711, 72497, 73495, 75709, 75836, 76481, 77401, 169947, 170184, 170184, 
      170752, 170810, 170865, 172795, 173215, 173353, 173441, 173717, 174055, 174618, 
      174952, 175279, 175413, 175680, 175750, 175891, 176315, 176386, 176585, 176652, 
      177577, 177649, 177721, 177789, 179048, 179280, 105431, 105969, 106108, 106243, 
      106312, 106502, 106557, 106615, 106737, 106802, 106965, 107368, 107575, 107643, 
      107769, 107832, 107892, 109940, 111115, 119238, 154270, 155976, 156271, 156686, 
      157400, 158200, 158883, 159997, 160571, 161383, 161443);
    SQL
    ["animals", "plants"].each do |t|
      puts "Importing #{t.capitalize}"
      tmp_table = "#{t}_import"
      drop_table(tmp_table)
      create_import_table(tmp_table)
      query = eval("#{t}_query")
      copy_data(tmp_table, query)
      tmp_columns = MAPPING[tmp_table][:tmp_columns]
      import_data_for tmp_table, Rank::KINGDOM if tmp_columns.include? Rank::KINGDOM.capitalize
      if tmp_columns.include?(Rank::PHYLUM.capitalize) && 
        tmp_columns.include?(Rank::CLASS.capitalize) &&
        tmp_columns.include?('TaxonOrder')
        import_data_for tmp_table, Rank::PHYLUM, Rank::KINGDOM
        import_data_for tmp_table, Rank::CLASS, Rank::PHYLUM
        import_data_for tmp_table, Rank::ORDER, Rank::CLASS, 'TaxonOrder'
      elsif tmp_columns.include?(Rank::CLASS.capitalize) && tmp_columns.include?('TaxonOrder')
        import_data_for tmp_table, Rank::CLASS, Rank::KINGDOM
        import_data_for tmp_table, Rank::ORDER, Rank::CLASS, 'TaxonOrder'
      elsif tmp_columns.include? 'TaxonOrder'
        import_data_for tmp_table, Rank::ORDER, Rank::KINGDOM, 'TaxonOrder'
      end
      import_data_for tmp_table, Rank::FAMILY, 'TaxonOrder', nil, Rank::ORDER
      import_data_for tmp_table, Rank::GENUS, Rank::FAMILY
      import_data_for tmp_table, Rank::SPECIES, Rank::GENUS
      import_data_for tmp_table, Rank::SUBSPECIES, Rank::SPECIES, 'SpcInfra'
    end
    #rebuild the tree
    TaxonConcept.rebuild!
    #set the depth on all nodes
    TaxonConcept.roots.each do |root|
      TaxonConcept.each_with_level(root.self_and_descendants) do |node, level|
        node.send(:"set_depth!")
      end
    end
    Sapi::rebuild_taxonomy()
  end
end

# Copies data from the temporary table to the correct tables in the database
#
# @param [String] which the column to be copied. It's normally the name of the rank being copied
# @param [String] parent_column to keep the hierarchy of the taxons the parent column should be passed
# @param [String] column_name if the which object is different from the column name in the tmp table, specify the column name
# @param [String] parent_rank if the parent_column is different from the rank name, specify parent rank
def import_data_for tmp_table, which, parent_column=nil, column_name=nil, parent_rank=nil
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
      parent_id, created_at, updated_at #{if [Rank::SPECIES, Rank::SUBSPECIES].include? which then ', legacy_id' end})
         SELECT
           tmp.taxon_name_id
           ,#{rank_id}
           ,tmp.designation_id
           ,taxon_concepts.id
           ,current_date
           ,current_date
           #{ if [Rank::SPECIES, Rank::SUBSPECIES].include? which then ', tmp.spcrecid' end}
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
