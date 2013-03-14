class AddConditionsApplyToEuDecisions < ActiveRecord::Migration
  def change
    add_column :eu_decisions, :conditions_apply, :boolean
  end
end
