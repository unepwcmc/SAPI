class AddIsCurrentToGeoEntities < ActiveRecord::Migration
  def change
    add_column :geo_entities, :is_current, :boolean, :default => true
  end
end
