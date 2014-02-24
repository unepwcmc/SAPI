class AddIsStrictToTradeValidationRules < ActiveRecord::Migration
  def up
    add_column :trade_validation_rules, :is_strict, :boolean
    Trade::ValidationRule.update_all({:is_strict => false})
    change_column :trade_validation_rules, :is_strict, :boolean, :null =>false, :default => false
  end
  def down
    remove_column :trade_validation_rules, :is_strict
  end
end
