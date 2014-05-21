class AddUpdatedByIdToEuDecisions < ActiveRecord::Migration
  def change
    add_column :eu_decisions, :updated_by_id, :integer
  end
end
