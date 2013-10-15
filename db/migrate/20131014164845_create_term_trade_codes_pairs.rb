class CreateTermTradeCodesPairs < ActiveRecord::Migration
  def change
    create_table :term_trade_codes_pairs do |t|
      t.integer :term_id
      t.integer :other_trade_code_id
      t.string :other_trade_code_type

      t.timestamps
    end

    add_foreign_key "term_trade_codes_pairs", "trade_codes", :name => "term_trade_codes_pairs_term_id", :column => "term_id"
    add_foreign_key "term_trade_codes_pairs", "trade_codes", :name => "term_trade_codes_pairs_other_trade_code_id", :column => "other_trade_code_id"
  end
end
