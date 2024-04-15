class AddManualIdAttributesToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :manual_id, :text
    add_column :documents, :volume, :integer
  end
end
