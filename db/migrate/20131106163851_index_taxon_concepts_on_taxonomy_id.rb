class IndexTaxonConceptsOnTaxonomyId < ActiveRecord::Migration
  def change
    add_index :taxon_concepts, :taxonomy_id
  end
end
