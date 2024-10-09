##
# This fixes an issue where species not listed in the checklist were being
# included in the autocomplete for the checklist.
# https://unep-wcmc.codebasehq.com/projects/cites-support-maintenance/tickets/103

class FixChecklistAutocomplete < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute 'DROP VIEW IF EXISTS auto_complete_taxon_concepts_view'
      execute "CREATE VIEW auto_complete_taxon_concepts_view AS #{view_sql('20240322120000', 'auto_complete_taxon_concepts_view')}"
      execute File.read(File.expand_path('../../mviews/011_rebuild_auto_complete_taxon_concepts_mview.sql', __FILE__))
      execute 'SELECT * FROM rebuild_auto_complete_taxon_concepts_mview()'
    end
  end

  def down
    safety_assured do
      execute 'DROP VIEW IF EXISTS auto_complete_taxon_concepts_view'
      execute "CREATE VIEW auto_complete_taxon_concepts_view AS #{view_sql('20230803181442', 'auto_complete_taxon_concepts_view')}"
      execute File.read(File.expand_path('../../mviews/011_rebuild_auto_complete_taxon_concepts_mview.sql', __FILE__))
      execute 'SELECT * FROM rebuild_auto_complete_taxon_concepts_mview()'
    end
  end
end
