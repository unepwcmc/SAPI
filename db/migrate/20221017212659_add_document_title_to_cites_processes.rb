class AddDocumentTitleToCitesProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :cites_processes, :document_title, :text
  end
end
