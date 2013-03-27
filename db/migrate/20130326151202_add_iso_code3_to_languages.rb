class AddIsoCode3ToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :iso_code3, :string
  end
end
