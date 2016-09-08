namespace :import do

  desc 'Import CITES quotas from csv file (usage: rake import:cites_quotas[path/to/file,path/to/another])'
  task :cites_quotas, 10.times.map { |i| "file_#{i}".to_sym } => [:environment] do |t, args|
    TMP_TABLE = 'quotas_import'

    if Quota.any?
      puts "Removing quotas related records"
      puts "#{TradeRestrictionSource.
        where(:trade_restriction_id => Quota.select(:id)).
        delete_all} trade restriction Sources deleted"
      puts "#{TradeRestrictionTerm.
        where(:trade_restriction_id => Quota.select(:id)).
        delete_all} trade restriction Term deleted"
      puts "#{Quota.delete_all} quotas deleted"
    end

    taxonomy_id = Taxonomy.where(:name => 'CITES_EU').first.id
    puts "There are #{Quota.count} CITES quotas in the database."
    files = files_from_args(t, args)
    files.each do |file|
      drop_table(TMP_TABLE)
      create_table_from_csv_headers(file, TMP_TABLE)
      copy_data(file, TMP_TABLE)

      puts "CREATING temporary column and view"
      ActiveRecord::Base.connection.execute(<<-SQL
        CREATE VIEW #{TMP_TABLE}_view AS
        SELECT DISTINCT ROW_NUMBER() OVER () AS row_id, * FROM #{TMP_TABLE}
        ORDER BY start_date
      SQL
      )
      ActiveRecord::Base.connection.execute("ALTER TABLE trade_restrictions DROP COLUMN IF EXISTS import_row_id")
      ActiveRecord::Base.connection.execute("ALTER TABLE trade_restrictions ADD COLUMN import_row_id integer")

      sql = <<-SQL
        INSERT INTO trade_restrictions(is_current, start_date, end_date, geo_entity_id, quota, publication_date,
          notes, type, unit_id, taxon_concept_id, public_display, url, created_at, updated_at, import_row_id)
        SELECT DISTINCT #{TMP_TABLE}_view.is_current, start_date, end_date, geo_entities.id, quota, publication_date,
          #{TMP_TABLE}_view.notes, 'Quota', units.id, taxon_concepts.id, public_display, url,
          CASE
            WHEN #{TMP_TABLE}_view.created_at IS NULL THEN current_date
            ELSE #{TMP_TABLE}_view.created_at
          END,
          CASE
            WHEN #{TMP_TABLE}_view.created_at IS NULL THEN current_date
            ELSE #{TMP_TABLE}_view.created_at
          END, #{TMP_TABLE}_view.row_id
          FROM #{TMP_TABLE}_view
          LEFT JOIN geo_entities ON UPPER(geo_entities.iso_code2) = UPPER(BTRIM(#{TMP_TABLE}_view.country_iso2)) AND geo_entities.legacy_type IN ('#{GeoEntityType::COUNTRY}', '#{GeoEntityType::TERRITORY}')
          LEFT JOIN ranks ON UPPER(ranks.name) = UPPER(BTRIM(#{TMP_TABLE}_view.rank))
          LEFT JOIN taxon_concepts ON taxon_concepts.legacy_id = #{TMP_TABLE}_view.legacy_id AND
            UPPER(taxon_concepts.legacy_type) = UPPER(BTRIM(#{TMP_TABLE}_view.kingdom)) AND taxon_concepts.taxonomy_id = #{taxonomy_id} AND
            taxon_concepts.rank_id = ranks.id
          LEFT JOIN trade_codes AS units ON UPPER(units.code) = UPPER(BTRIM(#{TMP_TABLE}_view.unit)) AND units.type = 'Unit'
          WHERE taxon_concepts.id IS NOT NULL AND geo_entities.id IS NOT NULL
      SQL

      ActiveRecord::Base.connection.execute(sql)

      # Add Terms & Sources Relationships
      ["terms", "sources"].each do |code|
        sql = <<-SQL
          WITH #{code}_codes_per_quota AS (
            SELECT row_id, regexp_split_to_table(quotas_import_view.#{code}, E',') AS code
            FROM #{TMP_TABLE}_view
          )
          INSERT INTO trade_restriction_#{code}(trade_restriction_id, #{code.singularize}_id, created_at, updated_at)
          SELECT trade_restrictions.id, trade_codes.id, current_date, current_date
          FROM #{code}_codes_per_quota as t
          INNER JOIN trade_restrictions ON trade_restrictions.import_row_id = t.row_id AND trade_restrictions.type = 'Quota'
          INNER JOIN trade_codes ON UPPER(trade_codes.code) = UPPER(BTRIM(t.code)) AND trade_codes.type = '#{code.singularize.titleize}'
        SQL
        puts "Linking #{code} to quotas"
        ActiveRecord::Base.connection.execute(sql)
      end
    end
    puts "DROPPING temporary column and view"
    ActiveRecord::Base.connection.execute("ALTER TABLE trade_restrictions DROP COLUMN import_row_id")
    ActiveRecord::Base.connection.execute("DROP VIEW #{TMP_TABLE}_view")

    puts "There are now #{Quota.count} CITES quotas in the database"
  end

end
