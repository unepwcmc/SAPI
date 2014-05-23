class AddDetailsToAdminIucnMappings < ActiveRecord::Migration
  def change
    add_column :admin_iucn_mappings, :details, :hstore
  end
end
