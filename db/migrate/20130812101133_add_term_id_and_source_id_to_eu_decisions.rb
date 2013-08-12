class AddTermIdAndSourceIdToEuDecisions < ActiveRecord::Migration
  def change
    add_column :eu_decisions, :term_id, :integer
    add_column :eu_decisions, :source_id, :integer

    add_foreign_key "eu_decisions", "trade_codes", :name => "eu_decisions_source_id_fk", :column => "source_id"
    add_foreign_key "eu_decisions", "trade_codes", :name => "eu_decisions_term_id_fk", :column => "term_id"
  end
end
