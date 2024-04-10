# https://github.com/ankane/ahoy/tree/v1.6.1#140
class Ahoy140UpgradeStep1 < ActiveRecord::Migration[4.2]
  def change
    safety_assured {
      rename_column :ahoy_events, :properties, :properties_json
      add_column :ahoy_events, :properties, :jsonb
    }
  end
end
