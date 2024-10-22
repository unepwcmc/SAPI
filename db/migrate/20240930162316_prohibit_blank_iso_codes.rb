class ProhibitBlankIsoCodes < ActiveRecord::Migration[7.1]
  def self.up
    safety_assured do
      execute "UPDATE geo_entities SET iso_code2 = NULL WHERE iso_code2 = '';"
      execute "UPDATE geo_entities SET iso_code3 = NULL WHERE iso_code3 = '';"
      add_check_constraint :geo_entities, '(char_length(iso_code2) = 2)', name: 'check_iso_code2_length'
      add_check_constraint :geo_entities, '(char_length(iso_code3) = 3)', name: 'check_iso_code3_length'
    end
  end

  def self.down
    remove_check_constraint :geo_entities, name: 'check_iso_code2_length'
    remove_check_constraint :geo_entities, name: 'check_iso_code3_length'
  end
end
