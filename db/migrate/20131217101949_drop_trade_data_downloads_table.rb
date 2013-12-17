class DropTradeDataDownloadsTable < ActiveRecord::Migration
  def up
    drop_table :trade_data_downloads
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
