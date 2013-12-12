class CreateTradeEntityGeoEntityType < ActiveRecord::Migration
  def up
  	GeoEntityType.create(:name => GeoEntityType::TRADE_ENTITY)
  end

  def down
  end
end
