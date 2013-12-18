  namespace :import do
      desc "Import trade permits from csv file"
      task :trade_permits => [:environment] do
        TMP_TABLE = "permits_import"
        file = "lib/files/permit_details.csv"
        drop_table(TMP_TABLE)
        create_table_from_csv_headers(file, TMP_TABLE)
        copy_data(file, TMP_TABLE)
      end
  end