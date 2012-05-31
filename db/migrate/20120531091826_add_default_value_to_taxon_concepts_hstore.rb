class AddDefaultValueToTaxonConceptsHstore < ActiveRecord::Migration
  def change
    change_column :taxon_concepts, :data, :hstore, :default => ''
  end
end
