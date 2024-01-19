class ChangeForeignKeyConstraintOnDeleteInDocumentDetails < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key(:proposal_details, :documents)
    remove_foreign_key(:review_details, :documents)
    add_foreign_key(:proposal_details, :documents, dependent: :delete)
    add_foreign_key(:review_details, :documents, dependent: :delete)
  end
end
