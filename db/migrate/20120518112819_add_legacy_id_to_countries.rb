class AddLegacyIdToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :legacy_id, :integer
  end
end
