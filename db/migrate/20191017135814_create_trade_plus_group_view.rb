class CreateTradePlusGroupView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS trade_plus_group_view"
    execute "CREATE VIEW trade_plus_group_view AS #{view_sql('20191030154249', 'trade_plus_group_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS trade_plus_group_view"
  end
end
