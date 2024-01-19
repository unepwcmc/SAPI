class AddElibLegacyIdToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :elib_legacy_id, :integer
  end
end
