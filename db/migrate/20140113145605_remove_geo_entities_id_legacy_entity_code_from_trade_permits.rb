class RemoveGeoEntitiesIdLegacyEntityCodeFromTradePermits < ActiveRecord::Migration
  def up
    remove_column :trade_permits, :geo_entity_id
    remove_column :trade_permits, :legacy_entity_code
  end

  def down
    add_column :trade_permits, :legacy_entity_code, :string
    add_column :trade_permits, :geo_entity_id, :string
  end
end
