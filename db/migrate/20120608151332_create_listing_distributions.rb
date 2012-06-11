class CreateListingDistributions < ActiveRecord::Migration
  def change
    create_table :listing_distributions do |t|
      t.integer :listing_change_id
      t.integer :geo_entity_id

      t.timestamps
    end
    add_foreign_key 'listing_distributions', 'listing_changes', :name => 'listing_distributions_listing_change_id_fk'
    add_foreign_key 'listing_distributions', 'geo_entities', :name => 'listing_distributions_geo_entity_id_fk'
  end
end
