class ChangeVarcharsToTextInTradeDownloads < ActiveRecord::Migration
  def up
    change_column :trade_trade_data_downloads, :importer, :text
    change_column :trade_trade_data_downloads, :exporter, :text
    change_column :trade_trade_data_downloads, :origin, :text
    change_column :trade_trade_data_downloads, :term, :text
    change_column :trade_trade_data_downloads, :unit, :text
    change_column :trade_trade_data_downloads, :source, :text
    change_column :trade_trade_data_downloads, :purpose, :text
  end

  def down
    change_column :trade_trade_data_downloads, :importer, :string
    change_column :trade_trade_data_downloads, :exporter, :string
    change_column :trade_trade_data_downloads, :origin, :string
    change_column :trade_trade_data_downloads, :term, :string
    change_column :trade_trade_data_downloads, :unit, :string
    change_column :trade_trade_data_downloads, :source, :string
    change_column :trade_trade_data_downloads, :purpose, :string
  end
end
