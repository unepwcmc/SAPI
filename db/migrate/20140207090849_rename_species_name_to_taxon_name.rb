class RenameSpeciesNameToTaxonName < ActiveRecord::Migration
  def up
    rename_column :trade_sandbox_template, :species_name, :taxon_name
  end

  def down
    rename_column :trade_sandbox_template, :taxon_name, :species_name
  end
end
