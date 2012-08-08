namespace :import do

  desc 'Import references from SQL Server [usage: rake import:references]'
  task :references => [:environment] do
    ANIMALS_QUERY = <<-SQL
      SELECT TOP 1000
           [DscRecID]
          ,[DscTitle]
          ,[DscAuthors]
          --,[DscPubPlace]
          --,[DscPublisher]
          ,[DscPubYear]
          --,[DscSource]
      FROM [Animals].[dbo].[DataSource];
    SQL
    PLANTS_QUERY = <<-SQL
      SELECT TOP 1000
           [DscRecID]
          ,[DscTitle]
          ,[DscAuthors]
          --,[DscPubPlace]
          --,[DscPublisher]
          ,[DscPubYear]
          --,[DscSource]
      FROM ORWELL.[Plants].[dbo].[DataSource];
    SQL
    TMP_TABLE = 'references_import'
    ["animals", "plants"].each do |t|
      puts "There are #{Reference.count} references in the database."
      drop_table(TMP_TABLE)
      create_import_table(TMP_TABLE)
      query = "#{t.upcase}_QUERY".constantize
      copy_data(TMP_TABLE, query)
      sql = <<-SQL
        INSERT INTO "references" (legacy_type, legacy_id, author, title, year,
          created_at, updated_at)
        SELECT '#{t}' AS legacy_type, DscRecID, DscAuthors, DscTitle, DscPubYear,
          current_date, current_date
          FROM #{TMP_TABLE}
          WHERE NOT EXISTS (
            SELECT legacy_type, legacy_id
            FROM "references"
            WHERE "references".legacy_id = #{TMP_TABLE}.DscRecID AND
              "references".legacy_type = '#{t}'
          )
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
    puts "There are now #{Reference.count} references in the database"
  end

end