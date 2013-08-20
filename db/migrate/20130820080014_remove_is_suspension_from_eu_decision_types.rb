class RemoveIsSuspensionFromEuDecisionTypes < ActiveRecord::Migration
  def up
    remove_column :eu_decision_types, :is_suspension
  end

  def down
    add_column :eu_decision_types, :is_suspension, :boolean
  end
end
