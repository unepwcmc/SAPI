class CreateTaxonConceptsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS taxon_concepts_view"
    execute "CREATE VIEW taxon_concepts_view AS #{view_sql('20160630084345', 'taxon_concepts_view')}"
  end

  def down
  end
end
