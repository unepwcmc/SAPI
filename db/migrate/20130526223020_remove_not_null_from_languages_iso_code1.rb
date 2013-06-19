class RemoveNotNullFromLanguagesIsoCode1 < ActiveRecord::Migration
  def up
  	execute 'ALTER TABLE languages ALTER iso_code1 DROP NOT NULL'
  end

  def down
  end
end
