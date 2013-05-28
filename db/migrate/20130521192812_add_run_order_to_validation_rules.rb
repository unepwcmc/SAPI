class AddRunOrderToValidationRules < ActiveRecord::Migration
  def change
    add_column :trade_validation_rules, :run_order, :integer
    Trade::ValidationRule.update_all({:run_order => 1}, {:type => ['Trade::PresenceValidationRule']})
    Trade::ValidationRule.update_all({:run_order => 2}, {:type => ['Trade::NumericalityValidationRule']})
    Trade::ValidationRule.update_all({:run_order => 3}, {:type => ['Trade::FormatValidationRule']})
    Trade::ValidationRule.update_all({:run_order => 4}, {:type => ['Trade::InclusionValidationRule']})
    execute 'ALTER TABLE trade_validation_rules ALTER run_order SET NOT NULL'
  end
end
