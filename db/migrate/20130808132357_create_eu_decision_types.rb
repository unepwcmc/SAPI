class CreateEuDecisionTypes < ActiveRecord::Migration
  def change
    create_table :eu_decision_types do |t|
      t.string :name
      t.string :tooltip

      t.timestamps
    end
  end
end
