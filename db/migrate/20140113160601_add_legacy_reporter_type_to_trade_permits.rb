class AddLegacyReporterTypeToTradePermits < ActiveRecord::Migration
  def change
    add_column :trade_permits, :legacy_reporter_type, :string
  end
end
