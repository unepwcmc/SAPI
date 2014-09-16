class AddExtendedDescriptionToEvents < ActiveRecord::Migration
  def change
    add_column :events, :extended_description, :text
  end
end
