class AddEventIdToAnnotation < ActiveRecord::Migration
  def change
    add_column :annotations, :event_id, :integer
    add_foreign_key :annotations, :events, :name => :annotations_event_id_fk
  end
end
