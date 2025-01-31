class SearchByNonHyphenatedCommonNameVersions < ActiveRecord::Migration[4.2]
  def up
    execute 'DROP VIEW IF EXISTS auto_complete_taxon_concepts_view'
    execute "CREATE VIEW auto_complete_taxon_concepts_view AS #{view_sql('20150318150923', 'auto_complete_taxon_concepts_view')}"
  end

  def down
    execute 'DROP VIEW IF EXISTS auto_complete_taxon_concepts_view'
    execute "CREATE VIEW auto_complete_taxon_concepts_view AS #{view_sql('20150223115540', 'auto_complete_taxon_concepts_view')}"
  end
end
