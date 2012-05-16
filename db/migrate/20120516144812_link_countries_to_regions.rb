class LinkCountriesToRegions < ActiveRecord::Migration
  def change
    add_column :countries, :region_id, :integer
    add_foreign_key "countries", "regions", :name => "countries_regions_id_fk", :column => "region_id"
  end
end
