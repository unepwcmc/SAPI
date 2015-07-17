class AddElibLegacyIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :elib_legacy_id, :integer
  end
end
