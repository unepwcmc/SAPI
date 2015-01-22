class CreateEuSuspensionsApplicabilityView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS eu_suspensions_applicability_view"
    execute "CREATE VIEW eu_suspensions_applicability_view AS #{view_sql('20150121234014', 'eu_suspensions_applicability_view')}"
  end

  def down
    execute "DROP VIEW eu_suspensions_applicability_view"
  end
end
