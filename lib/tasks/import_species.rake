require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do

  desc "Import species records from csv files (usage: rake import:species[path/to/file,path/to/another])"
  task :species, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'species_import'
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)
      db_columns = db_columns_from_csv_headers(file, TMP_TABLE, false)
      import_data_for Rank::KINGDOM if db_columns.include? Rank::KINGDOM.capitalize
      if db_columns.include?(Rank::PHYLUM.capitalize) && 
        db_columns.include?(Rank::CLASS.capitalize) &&
        db_columns.include?('TaxonOrder')
        import_data_for Rank::PHYLUM, Rank::KINGDOM
        import_data_for Rank::CLASS, Rank::PHYLUM
        import_data_for Rank::ORDER, Rank::CLASS, 'TaxonOrder'
      elsif db_columns.include?(Rank::CLASS.capitalize) && db_columns.include?('TaxonOrder')
        import_data_for Rank::CLASS, Rank::KINGDOM
        import_data_for Rank::ORDER, Rank::CLASS, 'TaxonOrder'
      elsif db_columns.include? 'TaxonOrder'
        import_data_for Rank::ORDER, Rank::KINGDOM, 'TaxonOrder'
      end
      import_data_for Rank::FAMILY, 'TaxonOrder', nil, Rank::ORDER
      import_data_for Rank::GENUS, Rank::FAMILY
      import_data_for Rank::SPECIES, Rank::GENUS
      import_data_for Rank::SUBSPECIES, Rank::SPECIES, 'SpcInfra'
    end
  end
end

# Copies data from the temporary table to the correct tables in the database
#
# @param [String] which the column to be copied. It's normally the name of the rank being copied
# @param [String] parent_column to keep the hierarchy of the taxons the parent column should be passed
# @param [String] column_name if the which object is different from the column name in the tmp table, specify the column name
# @param [String] parent_rank if the parent_column is different from the rank name, specify parent rank
def import_data_for which, parent_column=nil, column_name=nil, parent_rank=nil
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
      FROM #{TMP_TABLE}
      WHERE NOT EXISTS (
        SELECT scientific_name
        FROM taxon_names
        WHERE INITCAP(scientific_name) LIKE INITCAP(BTRIM(#{TMP_TABLE}.#{column_name}))
      ) AND BTRIM(#{column_name}) <> 'NULL'
  SQL
  ActiveRecord::Base.connection.execute(sql)

  cites = Designation.find_by_name(Designation::CITES)
  if parent_column
    sql = <<-SQL
      INSERT INTO taxon_concepts(taxon_name_id, rank_id, designation_id,
      parent_id, created_at, updated_at
      #{if [Rank::SPECIES, Rank::SUBSPECIES].include? which then ', author_year, legacy_id, legacy_type' end})
         SELECT
           tmp.taxon_name_id
           ,#{rank_id}
           ,tmp.designation_id
           ,taxon_concepts.id
           ,current_date
           ,current_date
           #{ if [Rank::SPECIES, Rank::SUBSPECIES].include? which then
              ",CASE
                  WHEN tmp.speciesauthor = 'Null' THEN NULL
                  ELSE tmp.speciesauthor
                END
              ,tmp.SpcRecID, tmp.Kingdom" 
            end}
         FROM
          (
            SELECT DISTINCT taxon_names.id AS taxon_name_id,
            #{TMP_TABLE}.#{parent_column}, #{cites.id} AS designation_id
            #{if [Rank::SPECIES, Rank::SUBSPECIES].include? which then ",INITCAP(BTRIM(#{which == Rank::SPECIES ? "#{TMP_TABLE}.speciesauthor" : "#{TMP_TABLE}.InfraRankAuthor"})) AS speciesauthor, #{TMP_TABLE}.SpcRecID, #{TMP_TABLE}.Kingdom" end}
            FROM #{TMP_TABLE}
            LEFT JOIN taxon_names ON (INITCAP(BTRIM(#{TMP_TABLE}.#{column_name})) LIKE INITCAP(BTRIM(taxon_names.scientific_name)))
            WHERE NOT EXISTS (
              SELECT taxon_name_id, rank_id, designation_id
              FROM taxon_concepts
              WHERE taxon_concepts.taxon_name_id = taxon_names.id AND
                taxon_concepts.rank_id = #{rank_id} AND
                taxon_concepts.designation_id = #{cites.id}
            )
            AND taxon_names.id IS NOT NULL
            #{
              if which == Rank::SPECIES then " AND BTRIM(#{TMP_TABLE}.SpcInfra) = 'NULL'"
              elsif which == Rank::SUBSPECIES then " AND BTRIM(#{TMP_TABLE}.SpcInfra) <> 'NULL'"
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
