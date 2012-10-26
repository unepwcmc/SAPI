class AddDefaultValueToStatus < ActiveRecord::Migration
  def change
    change_column :downloads, :status, :string, :default => "working"
  end
end
