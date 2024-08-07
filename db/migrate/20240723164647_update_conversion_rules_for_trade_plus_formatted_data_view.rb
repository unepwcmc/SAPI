# Updates
#
# - trade_plus_formatted_data_view and
# - trade_plus_formatted_data_final_view
#
# The rules for converting terms SID and COR were being applied to shipments
# where unit was NULL but not where unit was 'NAR'. This patch alters the views
# above so that both NULL and 'NAR' are treated in the same way for these rules.

class UpdateConversionRulesForTradePlusFormattedDataView < ActiveRecord::Migration[4.2]
  def up
    safety_assured do
      execute 'DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview'
      execute 'DROP VIEW IF EXISTS trade_plus_complete_view'
      execute 'DROP VIEW IF EXISTS trade_plus_formatted_data_final_view'
      execute 'DROP VIEW IF EXISTS trade_plus_formatted_data_view'
      execute 'DROP VIEW IF EXISTS trade_plus_group_view'
      execute 'DROP VIEW IF EXISTS trade_plus_shipments_view'
      execute "CREATE VIEW trade_plus_shipments_view AS #{view_sql('20200206150700', 'trade_plus_shipments_view')}"
      execute "CREATE VIEW trade_plus_group_view AS #{view_sql('20220223142356', 'trade_plus_group_view')}"
      execute "CREATE VIEW trade_plus_formatted_data_view AS #{view_sql('20240723164647', 'trade_plus_formatted_data_view')}"
      execute "CREATE VIEW trade_plus_formatted_data_final_view AS #{view_sql('20240723164647', 'trade_plus_formatted_data_final_view')}"
      execute "CREATE VIEW trade_plus_complete_view AS #{view_sql('20200707183829', 'trade_plus_complete_view')}"
      execute 'CREATE MATERIALIZED VIEW trade_plus_complete_mview AS SELECT * FROM trade_plus_complete_view WITH NO DATA'
      execute 'SELECT create_trade_plus_complete_mview_indexes()'
      # Don't do this during the migration, it will take over half an hour and
      # introduces a risk that the migration will fail, e.g. if ssh connection
      # is lost. Instead do it manually afterwards.
      #
      # execute 'REFRESH MATERIALIZED VIEW trade_plus_complete_mview'
    end
  end

  def down
    safety_assured do
      execute 'DROP MATERIALIZED VIEW IF EXISTS trade_plus_complete_mview'
      execute 'DROP VIEW IF EXISTS trade_plus_complete_view'
      execute 'DROP VIEW IF EXISTS trade_plus_formatted_data_final_view'
      execute 'DROP VIEW IF EXISTS trade_plus_formatted_data_view'
      execute 'DROP VIEW IF EXISTS trade_plus_group_view'
      execute 'DROP VIEW IF EXISTS trade_plus_shipments_view'
      execute "CREATE VIEW trade_plus_shipments_view AS #{view_sql('20200206150700', 'trade_plus_shipments_view')}"
      execute "CREATE VIEW trade_plus_group_view AS #{view_sql('20220223142356', 'trade_plus_group_view')}"
      execute "CREATE VIEW trade_plus_formatted_data_view AS #{view_sql('20220314110000', 'trade_plus_formatted_data_view')}"
      execute "CREATE VIEW trade_plus_formatted_data_final_view AS #{view_sql('20220119111417', 'trade_plus_formatted_data_final_view')}"
      execute "CREATE VIEW trade_plus_complete_view AS #{view_sql('20200707183829', 'trade_plus_complete_view')}"
      execute 'CREATE MATERIALIZED VIEW trade_plus_complete_mview AS SELECT * FROM trade_plus_complete_view WITH NO DATA'
      execute 'SELECT create_trade_plus_complete_mview_indexes()'
      # Don't do this during the migration, it will take over half an hour and
      # introduces a risk that the migration will fail, e.g. if ssh connection
      # is lost. Instead do it manually afterwards.
      #
      # execute 'REFRESH MATERIALIZED VIEW trade_plus_complete_mview'
    end
  end
end
