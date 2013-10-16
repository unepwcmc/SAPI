class AddIsPrimaryToValidationRules < ActiveRecord::Migration
  def change
    add_column :trade_validation_rules, :is_primary, :boolean
    Trade::ValidationRule.update_all(:is_primary => true)
    change_column :trade_validation_rules, :is_primary, :boolean, :default => true, :null => false
  end
end
