# https://github.com/ankane/ahoy/tree/v1.6.1#140
class Ahoy140UpgradeStep3 < ActiveRecord::Migration
  def change
    safety_assured {
      remove_column :ahoy_events, :properties_json
    }
  end
end
