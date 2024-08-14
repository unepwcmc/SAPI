class FixOrderOfDistributionTagsInPublicDistributionTab < ActiveRecord::Migration[4.2]
  def up
    execute 'DROP VIEW IF EXISTS api_distributions_view'
    execute "CREATE VIEW api_distributions_view AS #{view_sql('20160421083820', 'api_distributions_view')}"
  end

  def down
    execute 'DROP VIEW IF EXISTS api_distributions_view'
    execute "CREATE VIEW api_distributions_view AS #{view_sql('20150112093954', 'api_distributions_view')}"
  end
end
