class RecreateTradePlusFormattedDataView < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview"
    execute "DROP VIEW IF EXISTS trade_plus_complete_view"
    execute "DROP VIEW IF EXISTS trade_plus_formatted_data_final_view"
    execute "DROP VIEW IF EXISTS trade_plus_formatted_data_view"
    execute "CREATE VIEW trade_plus_formatted_data_view AS #{view_sql('2020070718281', 'trade_plus_formatted_data_view')}"
    execute "CREATE VIEW trade_plus_formatted_data_final_view AS #{view_sql('2020070814429', 'trade_plus_formatted_data_final_view')}"
    execute "CREATE VIEW trade_plus_complete_view AS #{view_sql('20200707183829', 'trade_plus_complete_view')}"
    execute "CREATE MATERIALIZED VIEW trade_plus_complete_mview AS SELECT * FROM trade_plus_complete_view"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview"
    execute "DROP VIEW IF EXISTS trade_plus_complete_view"
    execute "DROP VIEW IF EXISTS trade_plus_formatted_data_final_view"
    execute "DROP VIEW IF EXISTS trade_plus_formatted_data_view"
    execute "CREATE VIEW trade_plus_formatted_data_view AS #{view_sql('20191209215129', 'trade_plus_formatted_data_view')}"
    execute "CREATE VIEW trade_plus_complete_view AS #{view_sql('20191209215129', 'trade_plus_complete_view')}"
    execute "CREATE MATERIALIZED VIEW trade_plus_complete_mview AS SELECT * FROM trade_plus_complete_view"
  end
end
