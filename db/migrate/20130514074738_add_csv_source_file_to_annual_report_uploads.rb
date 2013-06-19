class AddCsvSourceFileToAnnualReportUploads < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :csv_source_file, :text
    remove_column :trade_annual_report_uploads, :original_filename
  end
end
