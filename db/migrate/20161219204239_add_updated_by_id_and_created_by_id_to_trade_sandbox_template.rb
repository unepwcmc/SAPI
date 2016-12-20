class AddUpdatedByIdAndCreatedByIdToTradeSandboxTemplate < ActiveRecord::Migration
  def change
    add_column :trade_sandbox_template, :updated_by_id, :integer
    add_column :trade_sandbox_template, :created_by_id, :integer
  end
end
