class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :iso3166_name, :null => false
      t.string :iso2_code
      t.string :iso3_code
      t.timestamps
    end
  end
end
