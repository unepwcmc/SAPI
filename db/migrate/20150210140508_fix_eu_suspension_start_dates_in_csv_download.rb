class FixEuSuspensionStartDatesInCsvDownload < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS eu_decisions_view"
    execute "CREATE VIEW eu_decisions_view AS #{view_sql('20150210140508', 'eu_decisions_view')}"
  end
end
