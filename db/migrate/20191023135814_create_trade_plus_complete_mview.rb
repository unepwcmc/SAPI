class CreateTradePlusCompleteMview < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview"
    execute "CREATE MATERIALIZED VIEW trade_plus_complete_mview AS #{view_sql('20191023141810', 'trade_plus_complete_mview')}"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview"
  end
end
