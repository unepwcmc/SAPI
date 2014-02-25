class RemoveLegacyReporterTypeFromTradePermits < ActiveRecord::Migration
  def up
    remove_column :trade_permits, :legacy_reporter_type
  end

  def down
    add_column :trade_permits, :legacy_reporter_type, :string
  end
end
