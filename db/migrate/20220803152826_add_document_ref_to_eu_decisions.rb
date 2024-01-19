class AddDocumentRefToEuDecisions < ActiveRecord::Migration[4.2]
  def change
    add_reference :eu_decisions, :document, index: true
  end
end
