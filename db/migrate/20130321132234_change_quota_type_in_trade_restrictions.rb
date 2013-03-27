class ChangeQuotaTypeInTradeRestrictions < ActiveRecord::Migration
  def up
    change_column :trade_restrictions, :quota, :float
  end

  def down
    change_column :trade_restrictions, :quota, :integer
  end
end
