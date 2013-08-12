class CreateEuDecisionConfirmations < ActiveRecord::Migration
  def change
    create_table :eu_decision_confirmations do |t|
      t.integer :eu_decision_id
      t.integer :event_id

      t.timestamps
    end
    add_foreign_key "eu_decision_confirmations", "eu_decisions", :name => "eu_decision_confirmations_eu_decision_id_fk"
    add_foreign_key "eu_decision_confirmations", "events", :name => "eu_decision_confirmations_event_id_fk"
  end
end
