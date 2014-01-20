class AddLegacyTradeCodesToTaxonConcepts < ActiveRecord::Migration
  def change
    add_column :taxon_concepts, :legacy_trade_code, :string
  end
end
