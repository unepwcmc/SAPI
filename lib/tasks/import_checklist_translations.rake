namespace :import do
  task checklist_translations: [
    :hash_annotations_cites_translations, :cites_regions_translations,
    :ranks_translations, :change_types_translations
  ]

  task ranks_translations: :environment do
    import_helper = CsvImportHelper.new

    TMP_TABLE = 'ranks_translations_import'
    file = 'lib/files/ranks.csv'

    import_helper.drop_table(TMP_TABLE)
    import_helper.create_table_from_csv_headers(file, TMP_TABLE)
    import_helper.copy_data(file, TMP_TABLE)

    sql = <<-SQL.squish
      UPDATE ranks
      SET display_name_fr = t.display_name_fr, display_name_es = t.display_name_es
      FROM #{TMP_TABLE} t
      WHERE UPPER(BTRIM(t.name)) = UPPER(BTRIM(ranks.name))
    SQL

    ApplicationRecord.connection.execute(sql)
  end

  task change_types_translations: :environment do
    import_helper = CsvImportHelper.new

    TMP_TABLE = 'change_types_translations_import'
    file = 'lib/files/change_types.csv'

    import_helper.drop_table(TMP_TABLE)
    import_helper.create_table_from_csv_headers(file, TMP_TABLE)
    import_helper.copy_data(file, TMP_TABLE)

    sql = <<-SQL.squish
      UPDATE change_types
      SET display_name_fr = t.display_name_fr, display_name_es = t.display_name_es
      FROM #{TMP_TABLE} t
      WHERE UPPER(BTRIM(t.name)) = UPPER(BTRIM(change_types.name))
    SQL

    ApplicationRecord.connection.execute(sql)
  end
end
