class CreateTradePlusStaticCompleteView < ActiveRecord::Migration[4.2]
  def up
    execute "DROP VIEW IF EXISTS trade_plus_static_complete_view"
    execute "CREATE VIEW trade_plus_static_complete_view AS #{view_sql('20190725122634', 'trade_plus_static_complete_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS trade_plus_static_complete_view"
  end
end
