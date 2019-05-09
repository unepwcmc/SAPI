class AddAwsStoragePathToAnnualReportUpload < ActiveRecord::Migration
  def change
    add_column :trade_annual_report_uploads, :aws_storage_path, :string
  end
end
