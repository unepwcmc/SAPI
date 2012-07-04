class RemoveSpcrecidFromTaxonConcepts < ActiveRecord::Migration
  def up
    remove_column :taxon_concepts, :spcrecid
  end

  def down
    add_column :taxon_concepts, :spcrecid, :integer
  end
end
