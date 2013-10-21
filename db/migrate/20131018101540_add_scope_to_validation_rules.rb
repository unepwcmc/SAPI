class AddScopeToValidationRules < ActiveRecord::Migration
  def change
  	add_column :trade_validation_rules, :scope, :hstore
  end
end
