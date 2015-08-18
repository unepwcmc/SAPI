class RemoveNullTagsFromDocumentsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS documents_view"
    execute "CREATE VIEW documents_view AS #{view_sql('20150817204542', 'documents_view')}"
  end

  def down
    execute "DROP VIEW IF EXISTS documents_view"
    execute "CREATE VIEW documents_view AS #{view_sql('20150720150338', 'documents_view')}"
  end
end
