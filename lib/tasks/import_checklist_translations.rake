namespace :import do

  task :checklist_translations => [
    :hash_annotations_cites_translations, :cites_regions_translations,
    :ranks_translations, :change_types_translations
  ]

  task :ranks_translations => :environment do
    TMP_TABLE = "ranks_translations_import"
    file = "lib/files/ranks.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    sql = <<-SQL
      UPDATE ranks
      SET display_name_fr = t.display_name_fr, display_name_es = t.display_name_es
      FROM #{TMP_TABLE} t
      WHERE UPPER(BTRIM(t.name)) = UPPER(BTRIM(ranks.name))
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

  task :change_types_translations => :environment do
    TMP_TABLE = "change_types_translations_import"
    file = "lib/files/change_types.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
    sql = <<-SQL
      UPDATE change_types
      SET display_name_fr = t.display_name_fr, display_name_es = t.display_name_es
      FROM #{TMP_TABLE} t
      WHERE UPPER(BTRIM(t.name)) = UPPER(BTRIM(change_types.name))
    SQL
    ActiveRecord::Base.connection.execute(sql)
  end

end
