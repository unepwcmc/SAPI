class AddSubtypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :subtype, :string
  end
end
