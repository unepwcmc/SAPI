class AddNotNullConstraintOnTermInTermTradeCodePairs < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS valid_term_unit_view"
    execute "DROP VIEW IF EXISTS valid_term_purpose_view"
    change_column :term_trade_codes_pairs, :term_id, :int, :null => false
  end

  def down
    execute "DROP VIEW IF EXISTS valid_term_unit_view"
    execute "DROP VIEW IF EXISTS valid_term_purpose_view"
    change_column :term_trade_codes_pairs, :term_id, :int, :null => true
  end
end
