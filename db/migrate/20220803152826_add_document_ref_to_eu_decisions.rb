class AddDocumentRefToEuDecisions < ActiveRecord::Migration
  def change
    add_reference :eu_decisions, :document, index: true
  end
end
