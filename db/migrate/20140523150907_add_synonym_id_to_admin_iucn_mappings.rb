class AddSynonymIdToAdminIucnMappings < ActiveRecord::Migration
  def change
    add_column :admin_iucn_mappings, :synonym_id, :integer
  end
end
