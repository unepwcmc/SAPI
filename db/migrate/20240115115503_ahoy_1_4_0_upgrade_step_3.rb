# https://github.com/ankane/ahoy/tree/v1.6.1#140
class Ahoy140UpgradeStep3 < ActiveRecord::Migration[4.2]
  def change
    safety_assured do
      remove_column :ahoy_events, :properties_json
    end
  end
end
