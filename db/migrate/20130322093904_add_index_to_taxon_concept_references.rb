class AddIndexToTaxonConceptReferences < ActiveRecord::Migration
  def change
    add_index :taxon_concept_references, ["taxon_concept_id", "reference_id"],
      :name => 'index_taxon_concept_references_on_taxon_concept_id_and_ref_id'
  end
end
