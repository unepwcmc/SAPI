# https://github.com/ankane/ahoy/tree/v1.6.1#140
# https://stackoverflow.com/a/31672314/556780
class Ahoy140UpgradeStep2 < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!
  def up
    Ahoy::Event.where(properties: nil).select(:id).find_in_batches do |events|
      Ahoy::Event.where(id: events.map(&:id)).update_all("properties = (regexp_replace(properties_json::text, '\\\\u0000', '', 'g'))::json::jsonb")
    end
  end
end
