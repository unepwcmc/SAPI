class CreateTradeCodesPairs < ActiveRecord::Migration
  def change
    create_table :trade_codes_pairs do |t|
      t.integer :trade_code_id
      t.string :trade_code_type
      t.integer :other_trade_code_id
      t.string :other_trade_code_type

      t.timestamps
    end

    add_foreign_key "trade_codes_pairs", "trade_codes", :name => "trade_codes_pairs_trade_code_id", :column => "trade_code_id"
    add_foreign_key "trade_codes_pairs", "trade_codes", :name => "trade_codes_pairs_other_trade_code_id", :column => "other_trade_code_id"
  end
end
