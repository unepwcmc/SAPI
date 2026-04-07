require Rails.root.join('lib/tasks/helpers_for_import.rb')
namespace :import do
  desc 'Import species records from csv files (usage: rake import:species[path/to/file,path/to/another])'
  task :species, 10.times.map { |i| :"file_#{i}" } => [ :environment ] do |t, args|
    import_helper = CsvImportHelper.new

    TMP_TABLE = 'species_import'

    files = import_helper.files_from_args(t, args)

    files.each do |file|
      import_helper.drop_table(TMP_TABLE)
      import_helper.create_table_from_csv_headers(file, TMP_TABLE)
      import_helper.copy_data(file, TMP_TABLE)

      kingdom = file.split('/').last.split('_')[0].titleize

      TaxonImportHelper.import_data_for_all_ranks(TMP_TABLE, kingdom)
    end
  end
end
