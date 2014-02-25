class AddUniqueIndexOnTermTradeCodesPairs < ActiveRecord::Migration
  def change
    add_index :term_trade_codes_pairs, [:term_id, :trade_code_id, :trade_code_type],
      :name => :index_term_trade_codes_pairs_on_term_and_trade_code, :unique => true
  end
end
