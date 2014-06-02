class CreateAdminIucnMappings < ActiveRecord::Migration
  def change
    create_table :admin_iucn_mappings do |t|
      t.integer :taxon_concept_id
      t.integer :iucn_taxon_id
      t.string :iucn_taxon_name
      t.string :iucn_author
      t.string :iucn_category

      t.timestamps
    end
  end
end
