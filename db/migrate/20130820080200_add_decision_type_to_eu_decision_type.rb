class AddDecisionTypeToEuDecisionType < ActiveRecord::Migration
  def change
    add_column :eu_decision_types, :decision_type, :string
  end
end
