class AddCreatedByIdToEuDecisions < ActiveRecord::Migration
  def change
    add_column :eu_decisions, :created_by_id, :integer
  end
end
