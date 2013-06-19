class CreateCitesSuspensionConfirmations < ActiveRecord::Migration
  def change
    create_table :cites_suspension_confirmations do |t|
      t.integer :cites_suspension_id
      t.integer :cites_suspension_notification_id

      t.timestamps
    end

    add_foreign_key :cites_suspension_confirmations, :trade_restrictions,
      :name => "cites_suspension_confirmations_cites_suspension_id_fk",
      :column => "cites_suspension_id"

    add_foreign_key :cites_suspension_confirmations, :events,
      :name => "cites_suspension_confirmations_notification_id_fk",
      :column => "cites_suspension_notification_id"

  end
end
