class AddLegacyIdAndEndDateToEvents < ActiveRecord::Migration
  def change
    add_column :events, :legacy_id, :integer
    add_column :events, :end_date, :datetime
  end
end
