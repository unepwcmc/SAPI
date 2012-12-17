class RenameAbbreviationToIsoCode1ForLanguages < ActiveRecord::Migration
  def up
    rename_column :languages, :abbreviation, :iso_code1
  end

  def down
    rename_column :languages, :iso_code1, :abbreviation
  end
end
