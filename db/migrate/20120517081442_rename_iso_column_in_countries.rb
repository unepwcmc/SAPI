class RenameIsoColumnInCountries < ActiveRecord::Migration
  def change
    rename_column :countries, :iso3166_name, :iso_name
  end
end
