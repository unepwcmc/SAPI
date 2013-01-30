class RebuildTaxonConceptsMview < ActiveRecord::Migration
  def change
    Sapi::rebuild_taxon_concepts_mview
  end
end
