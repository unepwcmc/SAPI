class CreateDocumentTags < ActiveRecord::Migration
  def change
    create_table :document_tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
