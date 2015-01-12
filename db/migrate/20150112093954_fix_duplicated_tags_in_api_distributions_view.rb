class FixDuplicatedTagsInApiDistributionsView < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS api_distributions_view"
    execute "CREATE VIEW api_distributions_view AS #{view_sql('20150112093954', 'api_distributions_view')}"
  end
end
