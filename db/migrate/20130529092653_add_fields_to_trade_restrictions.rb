class AddFieldsToTradeRestrictions < ActiveRecord::Migration
  def change
    change_table(:trade_restrictions) do |t|
      t.integer :start_notification_id
      t.integer :end_notification_id
    end
    add_column :trade_restrictions, :excluded_taxon_concepts_ids, 'INTEGER[]'
    add_foreign_key :trade_restrictions, :events,
      :name => :trade_restrictions_start_notification_id_fk,
      :column => :start_notification_id
    add_foreign_key :trade_restrictions, :events,
      :name => :trade_restrictions_end_notification_id_fk,
      :column => :end_notification_id
  end
end
