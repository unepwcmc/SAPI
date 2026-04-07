namespace :import do
  desc 'Apply name status changes from csv file (usage: rake import:taxon_name_status_changes[path/to/file,path/to/another])'
  task :taxon_name_status_changes, 10.times.map { |i| :"file_#{i}" } => [ :environment ] do |t, args|
    import_helper = CsvImportHelper.new

    TMP_TABLE = 'name_status_import'

    files = import_helper.files_from_args(t, args)

    ApplicationRecord.transaction do
      [ 'A', 'H', 'N', 'S', 'T' ].each do |name_status|
        puts "There are #{TaxonConcept.where(name_status:).count} #{name_status} names in the database."
      end

      files.each do |file|
        import_helper.drop_table(TMP_TABLE)
        import_helper.create_table_from_csv_headers(file, TMP_TABLE)
        import_helper.copy_data(file, TMP_TABLE)

        # Note: this will make NO changes to taxons where the IDs are not found,
        # and will simply ignore them.
        #
        # This is so we can test more easily on staging, which may not have all
        # the required taxons.
        ActiveRecord::Base.connection.execute(
          <<-SQL.squish
            SELECT itc.id, itc.name_status
            FROM #{TMP_TABLE} itc
            JOIN taxon_concepts tc ON itc.id = tc.id
            WHERE itc.name_status != tc.name_status
          SQL
        ).each_row do |row|
          # Use model because triggers exist
          tc = TaxonConcept.find(row[0])

          if tc
            tc.name_status = row[1]
            tc.save
          end
        end
      end

      [ 'A', 'H', 'N', 'S', 'T' ].each do |name_status|
        puts "There are #{TaxonConcept.where(name_status:).count} #{name_status} names in the database."
      end
    end
  end
end
