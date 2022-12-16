class CreateEuCountryDates < ActiveRecord::Migration
  def change
    create_table :eu_country_dates do |t|
      t.references :geo_entity
      t.integer :eu_accession_year
      t.integer :eu_exit_year
      t.timestamps
    end
  end
end
