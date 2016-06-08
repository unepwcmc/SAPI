class FixOrderOfDistributionTagsInPublicDistributionTabAgain < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS api_distributions_view"
    execute "CREATE VIEW api_distributions_view AS #{view_sql('20160425091139', 'api_distributions_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS api_distributions_view"
    execute "CREATE VIEW api_distributions_view AS #{view_sql('20160421083820', 'api_distributions_view')}"
  end
end
