class SetDefaultIsCurrentTrueForTradeRestrictions < ActiveRecord::Migration
  def up
    change_column :trade_restrictions, :is_current, :boolean, :default => true
  end

  def down
    change_column :trade_restrictions, :is_current, :boolean
  end
end
