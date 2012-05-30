class AddAbbreviationToTaxonNames < ActiveRecord::Migration
  def change
    add_column :taxon_names, :abbreviation, :string, :limit => 64
  end
end
