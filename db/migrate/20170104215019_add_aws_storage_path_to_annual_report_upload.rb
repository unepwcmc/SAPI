class AddAwsStoragePathToAnnualReportUpload < ActiveRecord::Migration[4.2]
  def change
    add_column :trade_annual_report_uploads, :aws_storage_path, :string
  end
end
