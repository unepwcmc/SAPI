class CreateApiDocumentsView < ActiveRecord::Migration[4.2]
  def up
    execute "CREATE VIEW api_documents_view AS #{view_sql('20150722113923', 'api_documents_view')}"
  end

  def down
    execute 'DROP VIEW IF EXISTS api_documents_view'
  end
end
