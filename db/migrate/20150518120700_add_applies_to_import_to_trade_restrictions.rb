class AddAppliesToImportToTradeRestrictions < ActiveRecord::Migration
  def change
    add_column :trade_restrictions, :applies_to_import, :boolean, null: false, default: false
  end
end
