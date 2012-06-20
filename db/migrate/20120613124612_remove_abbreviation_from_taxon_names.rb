class RemoveAbbreviationFromTaxonNames < ActiveRecord::Migration
  def change
    remove_column :taxon_names, :abbreviation
  end
end
