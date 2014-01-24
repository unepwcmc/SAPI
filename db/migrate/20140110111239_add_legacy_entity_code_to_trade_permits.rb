class AddLegacyEntityCodeToTradePermits < ActiveRecord::Migration
  def change
    add_column :trade_permits, :legacy_entity_code, :string
  end
end
