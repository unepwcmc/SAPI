class AddExtendedDescriptionToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :extended_description, :text
  end
end
