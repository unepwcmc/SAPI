class SimplifyEuSuspensionsApplicabilityView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS eu_suspensions_applicability_view CASCADE"
    execute "CREATE VIEW eu_suspensions_applicability_view AS #{view_sql('20150126135438', 'eu_suspensions_applicability_view')}"
    execute "CREATE VIEW eu_decisions_view AS #{view_sql('20150122132408', 'eu_decisions_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS eu_suspensions_applicability_view CASCADE"
    execute "CREATE VIEW eu_suspensions_applicability_view AS #{view_sql('20150121234014', 'eu_suspensions_applicability_view')}"
    execute "CREATE VIEW eu_decisions_view AS #{view_sql('20150122132408', 'eu_decisions_view')}"
  end
end
