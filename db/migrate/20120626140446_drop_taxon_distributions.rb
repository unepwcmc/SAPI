class DropTaxonDistributions < ActiveRecord::Migration
  def change
    drop_table :taxon_distributions
  end
end
