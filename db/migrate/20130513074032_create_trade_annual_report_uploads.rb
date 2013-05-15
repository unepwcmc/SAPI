class CreateTradeAnnualReportUploads < ActiveRecord::Migration
  def change
    create_table :trade_annual_report_uploads do |t|
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
    add_foreign_key "trade_annual_report_uploads", "users", :name => "trade_annual_report_uploads_created_by_fk", :column => 'created_by'
    add_foreign_key "trade_annual_report_uploads", "users", :name => "trade_annual_report_uploads_updated_by_fk", :column => 'updated_by'
  end
end
