class AddNumberToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :number, :string
  end
end
