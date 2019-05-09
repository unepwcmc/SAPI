class AddEpixFieldsToSandboxTemplate < ActiveRecord::Migration
  def change
    add_column :trade_sandbox_template, :epix_created_at, :timestamp
    add_column :trade_sandbox_template, :epix_updated_at, :timestamp
    add_column :trade_sandbox_template, :epix_created_by_id, :integer
    add_column :trade_sandbox_template, :epix_updated_by_id, :integer

    change_column_null :trade_annual_report_uploads, :created_at, true
    change_column_null :trade_annual_report_uploads, :updated_at, true
    change_column_null :trade_sandbox_template, :created_at, true
    change_column_null :trade_sandbox_template, :updated_at, true
  end
end
