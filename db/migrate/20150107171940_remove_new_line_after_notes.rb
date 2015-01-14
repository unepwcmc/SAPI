class RemoveNewLineAfterNotes < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS eu_decisions_view"
    execute "CREATE VIEW eu_decisions_view AS #{view_sql('20150107171940', 'eu_decisions_view')}"
  end
end
