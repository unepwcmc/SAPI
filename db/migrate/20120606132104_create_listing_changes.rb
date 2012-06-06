class CreateListingChanges < ActiveRecord::Migration
  def change
    create_table :listing_changes do |t|
      t.integer :species_listing_id
      t.integer :taxon_concept_id
      t.integer :change_type_id
      t.integer :reference_id
      t.integer :lft
      t.integer :rgt
      t.integer :parent_id
      t.integer :depth

      t.timestamps
    end

    add_foreign_key 'listing_changes', 'species_listings', :name => 'listing_changes_species_listing_id_fk'
    add_foreign_key 'listing_changes', 'taxon_concepts', :name => 'listing_changes_taxon_concept_id_fk'
    add_foreign_key 'listing_changes', 'listing_changes', :name => 'listing_changes_parent_id_fk', :column => 'parent_id'
    add_foreign_key 'listing_changes', 'change_types', :name => 'listing_changes_change_type_id_fk'
    add_foreign_key 'listing_changes', 'references', :name => 'listing_changes_reference_id_fk'
  end
end
