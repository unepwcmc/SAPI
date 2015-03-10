class AddOriginalStartDateToEuDecisionsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS eu_decisions_view"
    execute "CREATE VIEW eu_decisions_view AS #{view_sql('20150122132408', 'eu_decisions_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS eu_decisions_view"
    execute "CREATE VIEW eu_decisions_view AS #{view_sql('20150107171940', 'eu_decisions_view')}"
  end
end
