class AddInclusionTaxonConceptId < ActiveRecord::Migration
  def up
    add_column :listing_changes, :inclusion_taxon_concept_id, :integer
    add_foreign_key "listing_changes", "taxon_concepts", :name => "listing_changes_inclusion_taxon_concept_id_fk"
  end

  def down
    remove_column :listing_changes, :inclusion_taxon_concept_id
  end
end
