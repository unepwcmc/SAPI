class AddIndexOnTaxonConceptsHstore < ActiveRecord::Migration
  def up
    execute "CREATE INDEX index_taxon_concepts_on_data ON taxon_concepts USING BTREE (data)"
  end

  def down
    execute "DROP INDEX index_taxon_concepts_on_data"
  end
end
