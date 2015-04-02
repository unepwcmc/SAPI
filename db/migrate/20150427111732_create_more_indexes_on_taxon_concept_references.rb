class CreateMoreIndexesOnTaxonConceptReferences < ActiveRecord::Migration
  def up
    add_index "taxon_concept_references", ["is_standard", "is_cascaded", "taxon_concept_id"],
      name: "index_taxon_concept_references_on_tc_id_is_std_is_cascaded"
  end

  def down
    remove_index "taxon_concept_references",
      name: "index_taxon_concept_references_on_tc_id_is_std_is_cascaded"
  end
end
