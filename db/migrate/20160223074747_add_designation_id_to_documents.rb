class AddDesignationIdToDocuments < ActiveRecord::Migration
  def change
    add_column(:documents, :designation_id, :integer)
    add_foreign_key(:documents, :designations, dependent: :nullify)
  end
end
