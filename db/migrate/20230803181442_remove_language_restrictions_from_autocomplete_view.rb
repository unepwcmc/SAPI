class RemoveLanguageRestrictionsFromAutocompleteView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS auto_complete_taxon_concepts_view"
    execute "CREATE VIEW auto_complete_taxon_concepts_view AS #{view_sql('20230803181442', 'auto_complete_taxon_concepts_view')}"
    execute File.read(File.expand_path('../../mviews/011_rebuild_auto_complete_taxon_concepts_mview.sql', __FILE__))
    execute "SELECT * FROM rebuild_auto_complete_taxon_concepts_mview()"
  end

  def down
    execute "DROP VIEW IF EXISTS auto_complete_taxon_concepts_view"
    execute "CREATE VIEW auto_complete_taxon_concepts_view AS #{view_sql('20220808123526', 'auto_complete_taxon_concepts_view')}"
    execute File.read(File.expand_path('../../mviews/011_rebuild_auto_complete_taxon_concepts_mview.sql', __FILE__))
    execute "SELECT * FROM rebuild_auto_complete_taxon_concepts_mview()"
  end
end
