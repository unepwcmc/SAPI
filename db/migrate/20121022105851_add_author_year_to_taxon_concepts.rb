class AddAuthorYearToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :author_year, :string
  end
end
