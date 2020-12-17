class CreateTradePlusCompleteMview < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS trade_plus_complete_view"
    execute "CREATE VIEW trade_plus_complete_view AS #{view_sql('20191023141810', 'trade_plus_complete_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS trade_plus_complete_view"
  end
end
