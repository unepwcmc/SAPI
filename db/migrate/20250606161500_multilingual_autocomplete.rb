class MultilingualAutocomplete < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      execute 'DROP VIEW IF EXISTS auto_complete_taxon_concepts_view'
      execute "CREATE VIEW auto_complete_taxon_concepts_view AS #{view_sql('20250606161500', 'auto_complete_taxon_concepts_view')}"
      execute File.read(File.expand_path('../../mviews/001_rebuild_taxon_concepts_mview.sql', __FILE__))
      execute 'SELECT * FROM rebuild_auto_complete_taxon_concepts_mview()'
    end
  end

  def down
    safety_assured do
      execute 'DROP VIEW IF EXISTS auto_complete_taxon_concepts_view'
      execute "CREATE VIEW auto_complete_taxon_concepts_view AS #{view_sql('20240322120000', 'auto_complete_taxon_concepts_view')}"
      execute File.read(File.expand_path('../../mviews/001_rebuild_taxon_concepts_mview.sql', __FILE__))
      execute 'SELECT * FROM rebuild_auto_complete_taxon_concepts_mview()'
    end
  end
end
