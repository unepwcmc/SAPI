class IndexDistributionsOnTaxonConceptId < ActiveRecord::Migration
  def change
    add_index :distributions, :taxon_concept_id
  end
end
