class SetDefaultValueForIsCurrentToTrueInEuDecisions < ActiveRecord::Migration
  def up
    change_column :eu_decisions, :is_current, :boolean, :default => true
  end

  def down
    change_column :eu_decisions, :is_current, :boolean
  end
end
