class AddFieldsToAnnualReportUploads < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :original_filename, :string
    add_column :trade_annual_report_uploads, :number_of_rows, :integer
  end
end
