class CreateTradePlusWithTaxaView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS trade_plus_with_taxa_view"
    execute "CREATE VIEW trade_plus_with_taxa_view AS #{view_sql('20191030154249', 'trade_plus_with_taxa_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS trade_plus_with_taxa_view"
  end
end
