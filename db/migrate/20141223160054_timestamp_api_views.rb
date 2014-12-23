class TimestampApiViews < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS api_cites_quotas_view"
    execute "CREATE VIEW api_cites_quotas_view AS #{view_sql('20141223160054', 'api_cites_quotas_view')}"
    execute "DROP VIEW IF EXISTS api_cites_suspensions_view"
    execute "CREATE VIEW api_cites_suspensions_view AS #{view_sql('20141223160054', 'api_cites_suspensions_view')}"
    execute "DROP VIEW IF EXISTS api_common_names_view"
    execute "CREATE VIEW api_common_names_view AS #{view_sql('20141223160054', 'api_common_names_view')}"
    execute "DROP VIEW IF EXISTS api_distributions_view"
    execute "CREATE VIEW api_distributions_view AS #{view_sql('20141223160054', 'api_distributions_view')}"
    execute "DROP VIEW IF EXISTS api_eu_decisions_view"
    execute "CREATE VIEW api_eu_decisions_view AS #{view_sql('20141223160054', 'api_eu_decisions_view')}"
    execute "DROP TYPE IF EXISTS higher_taxa"
    execute "DROP TYPE IF EXISTS simple_taxon_concept"
    execute "DROP VIEW IF EXISTS api_taxon_concepts_view"
    execute "CREATE VIEW api_taxon_concepts_view AS #{view_sql('20141223160054', 'api_taxon_concepts_view')}"
  end
end
