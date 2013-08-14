class AddIsSuspensionToEuDecisionTypes < ActiveRecord::Migration
  def change
    add_column :eu_decision_types, :is_suspension, :boolean
  end
end
