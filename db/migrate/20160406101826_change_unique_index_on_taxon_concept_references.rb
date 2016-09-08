class ChangeUniqueIndexOnTaxonConceptReferences < ActiveRecord::Migration
  def up
    remove_index "taxon_concept_references",
      name: "index_taxon_concept_references_on_tc_id_is_std_is_cascaded"

    add_index "taxon_concept_references", ["taxon_concept_id", "reference_id", "is_standard", "is_cascaded"], name: "index_taxon_concept_references_on_tc_id_is_std_is_cascaded", unique: true

    remove_index "taxon_concept_references",
      name: "index_taxon_concept_references_on_taxon_concept_id_and_ref_id"
  end

  def down
    remove_index "taxon_concept_references",
      name: "index_taxon_concept_references_on_tc_id_is_std_is_cascaded"

    add_index "taxon_concept_references", ["taxon_concept_id", "reference_id", "is_standard", "is_cascaded"], name: "index_taxon_concept_references_on_tc_id_is_std_is_cascaded"

    add_index "taxon_concept_references", ["taxon_concept_id", "reference_id"],
      name: "index_taxon_concept_references_on_taxon_concept_id_and_ref_id"
  end
end
