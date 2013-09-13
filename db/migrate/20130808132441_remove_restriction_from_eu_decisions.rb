class RemoveRestrictionFromEuDecisions < ActiveRecord::Migration
  def up
    remove_column :eu_decisions, :restriction
    add_column :eu_decisions, :eu_decision_type_id, :integer
    add_foreign_key "eu_decisions", "eu_decision_types", :name => "eu_decisions_eu_decision_type_id_fk"
  end

  def down
    add_column :eu_decisions, :restriction, :string
    remove_column :eu_decisions, :eu_decision_type_id
  end
end
