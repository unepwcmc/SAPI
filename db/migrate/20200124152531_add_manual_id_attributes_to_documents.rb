class AddManualIdAttributesToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :manual_id, :text
    add_column :documents, :volume, :integer
  end
end
