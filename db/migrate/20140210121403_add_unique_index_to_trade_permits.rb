class AddUniqueIndexToTradePermits < ActiveRecord::Migration
  def change
    add_index "trade_permits", :number, :name => "trade_permits_number_idx", :unique => true
  end
end
