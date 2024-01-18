# https://github.com/ankane/ahoy/tree/v1.6.1#140
class Ahoy140UpgradeStep0 < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :ahoy_events, [:name, :time], algorithm: :concurrently
  end
end
