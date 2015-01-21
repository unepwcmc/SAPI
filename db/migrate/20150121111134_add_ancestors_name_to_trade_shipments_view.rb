class AddAncestorsNameToTradeShipmentsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS trade_shipments_with_taxa_view"
    execute "CREATE VIEW trade_shipments_with_taxa_view AS #{view_sql('20150121111134', 'trade_shipments_with_taxa_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS trade_shipments_with_taxa_view"
    execute "CREATE VIEW trade_shipments_with_taxa_view AS #{view_sql('20141223141125', 'trade_shipments_with_taxa_view')}"
  end
end
