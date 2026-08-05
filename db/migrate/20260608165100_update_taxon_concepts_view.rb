class UpdateTaxonConceptsView < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute "CREATE OR REPLACE VIEW taxon_concepts_view AS #{view_sql('20260608165100', 'taxon_concepts_view')}"
    end
  end

  def down
    execute "CREATE OR REPLACE VIEW taxon_concepts_view AS #{view_sql('20160630084345', 'taxon_concepts_view')}"
  end
end
