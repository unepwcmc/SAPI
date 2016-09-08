class FixSynonymsAndTradeNamesViewToExcludeInterTaxonomicRelationships < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS synonyms_and_trade_names_view"
    execute "CREATE VIEW synonyms_and_trade_names_view AS #{view_sql('20160405104833', 'synonyms_and_trade_names_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS synonyms_and_trade_names_view"
    execute "CREATE VIEW synonyms_and_trade_names_view AS #{view_sql('20150310140649', 'synonyms_and_trade_names_view')}"
  end
end
