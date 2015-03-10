class AddDependentsUpdatedByIdToInternalDownloadViews < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS taxon_concepts_names_view"
    execute "CREATE VIEW taxon_concepts_names_view AS #{view_sql('20150310140649', 'taxon_concepts_names_view')}"
    execute "DROP VIEW IF EXISTS synonyms_and_trade_names_view"
    execute "CREATE VIEW synonyms_and_trade_names_view AS #{view_sql('20150310140649', 'synonyms_and_trade_names_view')}"
    execute "DROP VIEW IF EXISTS orphaned_taxon_concepts_view"
    execute "CREATE VIEW orphaned_taxon_concepts_view AS #{view_sql('20150310140649', 'orphaned_taxon_concepts_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS taxon_concepts_names_view"
    execute "CREATE VIEW taxon_concepts_names_view AS #{view_sql('20150126125749', 'taxon_concepts_names_view')}"
    execute "DROP VIEW IF EXISTS synonyms_and_trade_names_view"
    execute "CREATE VIEW synonyms_and_trade_names_view AS #{view_sql('20150126125749', 'synonyms_and_trade_names_view')}"
    execute "DROP VIEW IF EXISTS orphaned_taxon_concepts_view"
    execute "CREATE VIEW orphaned_taxon_concepts_view AS #{view_sql('20150126125749', 'orphaned_taxon_concepts_view')}"
  end
end
