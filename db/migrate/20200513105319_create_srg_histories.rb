class CreateSrgHistories < ActiveRecord::Migration
  def up
    create_table :srg_histories do |t|
      t.string :name
      t.string :tooltip

      t.timestamps
    end

    add_column :eu_decisions, :srg_history_id, :integer
    add_foreign_key :eu_decisions, :srg_histories, name: 'eu_decisions_srg_history_id_fk'
  end

  def down
    remove_foreign_key :eu_decisions, name: 'eu_decisions_srg_history_id_fk'
    remove_column :eu_decisions, :srg_history_id
    drop_table :srg_histories
  end
end