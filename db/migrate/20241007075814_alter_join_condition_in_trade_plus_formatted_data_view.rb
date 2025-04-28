##
# This fixes an issue with the trade plus formatted data view where previously
# only one trade conversion rule from the TradeConversionRules table (sourced
# from `trade_mappings.yml`) would ever be applied; now the first rule in the
# group `standardise_terms` is applied, then the first rule in the group
# `standardise_units` is applied, finally the first rule in the group
# `standardise_terms_and_units` is applied; each rule uses the output of any
# rules previously applied.
#
# Shipments affected by this change include those of `Gonystylus bancanus` with
# term `TIP`, which should be converted to TIM then converted from KGM to MTQ.
#
class AlterJoinConditionInTradePlusFormattedDataView < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      # The view has the same columns and types as the view we are replacing,
      # therefore it is safe to simply use CREATE OR REPLACE VIEW, meaning
      # there is no need to replace dependant objects.
      execute "CREATE OR REPLACE VIEW trade_plus_formatted_data_view AS #{view_sql('20241006160000', 'trade_plus_formatted_data_view')}"

      # Don't do this during the migration, it will take over half an hour and
      # introduces a risk that the migration will fail, e.g. if ssh connection
      # is lost. Instead do it manually afterwards.
      #
      # execute 'REFRESH MATERIALIZED VIEW trade_plus_complete_mview'
    end
  end

  def down
    safety_assured do
      # The view has the same columns and types as the view we are replacing,
      # therefore it is safe to simply use CREATE OR REPLACE VIEW, meaning
      # there is no need to replace dependant objects.
      execute "CREATE OR REPLACE VIEW trade_plus_formatted_data_view AS #{view_sql('20240726140000', 'trade_plus_formatted_data_view')}"

      # Don't do this during the migration, it will take over half an hour and
      # introduces a risk that the migration will fail, e.g. if ssh connection
      # is lost. Instead do it manually afterwards.
      #
      # execute 'REFRESH MATERIALIZED VIEW trade_plus_complete_mview'
    end
  end
end
