class AddIndicesToMaterializedTaxonConceptsView < ActiveRecord::Migration
  def up
    execute "CREATE INDEX index_taxon_concepts_mview_on_full_name ON taxon_concepts_mview (full_name)"
    execute "CREATE INDEX index_taxon_concepts_mview_on_taxonomic_position ON taxon_concepts_mview (taxonomic_position)"
  end
  def down
    execute "DROP INDEX index_taxon_concepts_mview_on_full_name"
    execute "DROP INDEX index_taxon_concepts_mview_on_taxonomic_position"
  end
end
