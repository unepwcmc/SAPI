class RemoveCountriesRegionsAndBrus < ActiveRecord::Migration
  def up
    remove_foreign_key "countries", :name => "countries_regions_id_fk", :column => "region_id"
    drop_table :regions
    remove_foreign_key "brus", :name => "brus_parent_id_fk", :column => "parent_id"
    remove_foreign_key "brus", :name => "brus_country_id_fk"
    drop_table :countries
    drop_table :brus
  end

  def down
  end
end
