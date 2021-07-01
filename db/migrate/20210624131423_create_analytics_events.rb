class CreateAnalyticsEvents < ActiveRecord::Migration
  def change
    create_table :analytics_events do |t|
      t.string :event_type
      t.string :event_name

      t.timestamps
    end
  end
end
