class AddFormatReToTradeValidationRules < ActiveRecord::Migration
  def change
    add_column :trade_validation_rules, :format_re, :string
  end
end
