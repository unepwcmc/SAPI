class AddDocumentTitleToCitesProcesses < ActiveRecord::Migration
  def change
    add_column :cites_processes, :document_title, :text
  end
end
