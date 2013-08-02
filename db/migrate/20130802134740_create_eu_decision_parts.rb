class CreateEuDecisionParts < ActiveRecord::Migration
  def change
    create_table :eu_decision_parts do |t|
      t.boolean :is_current
      t.integer :source_id
      t.integer :term_id
      t.integer :eu_decision_id

      t.timestamps
    end
    add_foreign_key "eu_decision_parts", "trade_codes", :name => "eu_decision_parts_source_id_fk", :column => "source_id"
    add_foreign_key "eu_decision_parts", "trade_codes", :name => "eu_decision_parts_term_id_fk", :column => "term_id"
    add_foreign_key "eu_decision_parts", "eu_decisions", :name => "eu_decision_parts_eu_decision_id_fk"
  end
end
