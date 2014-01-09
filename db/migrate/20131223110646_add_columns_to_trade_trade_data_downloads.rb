class AddColumnsToTradeTradeDataDownloads < ActiveRecord::Migration
  def change
    add_column :trade_trade_data_downloads, :city, :varchar
    add_column :trade_trade_data_downloads, :country, :varchar
    add_column :trade_trade_data_downloads, :organization, :varchar
  end
end
