class AddCitesNameStatusToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :cites_name_status, :string
  end
end
