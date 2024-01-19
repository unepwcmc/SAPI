class CreateDocumentTags < ActiveRecord::Migration[4.2]
  def change
    create_table :document_tags do |t|
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
