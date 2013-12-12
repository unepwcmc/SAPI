namespace :import do
  desc "Import names from csv file"
  task :names_for_transfer => [:environment] do
    TMP_TABLE = "names_for_transfer_import"
    file = "lib/files/names_for_transfer.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
  end
    desc "Import names from csv file"
  task :shipments => [:environment] do
    TMP_TABLE = "shipments_import"
    file = "lib/files/SHIPMENT_DETAILS_DATA_TABLE.csv"
    drop_table(TMP_TABLE)
    create_table_from_csv_headers(file, TMP_TABLE)
    copy_data(file, TMP_TABLE)
  end
end