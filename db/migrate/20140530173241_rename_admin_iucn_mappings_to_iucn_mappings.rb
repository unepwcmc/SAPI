class RenameAdminIucnMappingsToIucnMappings < ActiveRecord::Migration
  def change
    rename_table :admin_iucn_mappings, :iucn_mappings
  end
end
