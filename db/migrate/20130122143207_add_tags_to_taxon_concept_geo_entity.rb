class AddTagsToTaxonConceptGeoEntity < ActiveRecord::Migration
  def change
    add_column :taxon_concept_geo_entities, :tags, :string
  end
end
