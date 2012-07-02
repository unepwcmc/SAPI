class ChangeListingDistriubutionsConstraints < ActiveRecord::Migration
  def change
    change_column :listing_distributions, :listing_change_id, :integer, :null => false
    change_column :listing_distributions, :geo_entity_id, :integer, :null => false
  end
end
