class TradeValidationRuleColumnNamesToBeArray < ActiveRecord::Migration
  def change
    unless Trade::ValidationRule.columns_hash["column_names"].array
      change_column :trade_validation_rules, :column_names, "varchar[] USING (string_to_array(column_names, ','))"
    end
  end
end
