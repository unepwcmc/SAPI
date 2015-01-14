class AddLanguageNamesToApiCommonNamesView < ActiveRecord::Migration
  def change
    execute "DROP VIEW IF EXISTS api_common_names_view"
    execute "CREATE VIEW api_common_names_view AS #{view_sql('20150112080319', 'api_common_names_view')}"
  end
end
