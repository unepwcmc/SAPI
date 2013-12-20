class AddNumberOfRowsColumnToTradeDataDownload < ActiveRecord::Migration
  def change
    add_column :trade_trade_data_downloads, :number_of_rows, :integer
  end
end
