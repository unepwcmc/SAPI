class CreateTermTradeCodesPairs < ActiveRecord::Migration
  def change
    create_table :term_trade_codes_pairs do |t|
      t.integer :term_id
      t.integer :trade_code_id
      t.string :trade_code_type

      t.timestamps
    end

    add_foreign_key "term_trade_codes_pairs", "trade_codes", :name => "term_trade_codes_pairs_term_id", :column => "term_id"
    add_foreign_key "term_trade_codes_pairs", "trade_codes", :name => "term_trade_codes_pairs_trade_code_id", :column => "trade_code_id"
  end
end
