class AddNumberToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :number, :string
  end
end
