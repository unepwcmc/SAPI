class AddMultilingualAndFixFormattingIssueOnTradePlusView < ActiveRecord::Migration
  def up
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview"
    execute "DROP VIEW IF EXISTS trade_plus_complete_view"
    execute "DROP VIEW IF EXISTS trade_plus_formatted_data_final_view"
    execute "DROP VIEW IF EXISTS trade_plus_formatted_data_view"
    execute "DROP VIEW IF EXISTS trade_plus_group_view"
    execute "DROP VIEW IF EXISTS trade_plus_shipments_view"
    execute "CREATE VIEW trade_plus_shipments_view AS #{view_sql('20200206150700', 'trade_plus_shipments_view')}"
    execute "CREATE VIEW trade_plus_group_view AS #{view_sql('20211005144857', 'trade_plus_group_view')}"
    execute "CREATE VIEW trade_plus_formatted_data_view AS #{view_sql('20211005144857', 'trade_plus_formatted_data_view')}"
    execute "CREATE VIEW trade_plus_formatted_data_final_view AS #{view_sql('20220119111417', 'trade_plus_formatted_data_final_view')}"
    execute "CREATE VIEW trade_plus_complete_view AS #{view_sql('20200707183829', 'trade_plus_complete_view')}"
    execute "CREATE MATERIALIZED VIEW trade_plus_complete_mview AS SELECT * FROM trade_plus_complete_view"
    # execute File.read(Rails.root.join("db/mviews/010_rebuild_trade_plus_mviews.sql"))
    # execute "SELECT * FROM rebuild_trade_plus_complete_mview()"
  end

  def down
    execute "DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview"
    execute "DROP VIEW IF EXISTS trade_plus_complete_view"
    execute "DROP VIEW IF EXISTS trade_plus_formatted_data_final_view"
    execute "DROP VIEW IF EXISTS trade_plus_formatted_data_view"
    execute "DROP VIEW IF EXISTS trade_plus_group_view"
    execute "DROP VIEW IF EXISTS trade_plus_shipments_view"
    execute "CREATE VIEW trade_plus_shipments_view AS #{view_sql('20200206150700', 'trade_plus_shipments_view')}"
    execute "CREATE VIEW trade_plus_group_view AS #{view_sql('20210823165358', 'trade_plus_group_view')}"
    execute "CREATE VIEW trade_plus_formatted_data_view AS #{view_sql('20210106174249', 'trade_plus_formatted_data_view')}"
    execute "CREATE VIEW trade_plus_formatted_data_final_view AS #{view_sql('20210106174249', 'trade_plus_formatted_data_final_view')}"
    execute "CREATE VIEW trade_plus_complete_view AS #{view_sql('20191209215129', 'trade_plus_complete_view')}"
    execute "CREATE MATERIALIZED VIEW trade_plus_complete_mview AS SELECT * FROM trade_plus_complete_view"
  end
end
