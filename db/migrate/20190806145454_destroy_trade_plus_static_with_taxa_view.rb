class DestroyTradePlusStaticWithTaxaView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS trade_plus_static_complete_view"
    execute "DROP VIEW IF EXISTS trade_plus_static_with_taxa_view"
    execute "CREATE VIEW trade_plus_static_complete_view AS #{view_sql('20190725122634', 'trade_plus_static_complete_view')}"
  end
end
