class AddEmptyStringAsDefaultToNotes < ActiveRecord::Migration
  def change
    [:en, :es, :fr].each do |lng|
      change_column :nomenclature_change_outputs, :"note_#{lng}", :text, default: ''
      change_column :nomenclature_change_inputs, :"note_#{lng}", :text, default: ''
    end
    change_column :nomenclature_change_outputs, :internal_note, :text, default: ''
    change_column :nomenclature_change_inputs, :internal_note, :text, default: ''

    ActiveRecord::Base.connection.execute(
      <<-SQL
        UPDATE nomenclature_change_outputs
        SET note_en=''
        WHERE note_en IS NULL;

        UPDATE nomenclature_change_outputs
        SET note_es=''
        WHERE note_es IS NULL;

        UPDATE nomenclature_change_outputs
        SET note_fr=''
        WHERE note_fr IS NULL;

        UPDATE nomenclature_change_outputs
        SET internal_note=''
        WHERE internal_note IS NULL;

        UPDATE nomenclature_change_inputs
        SET note_en=''
        WHERE note_en IS NULL;

        UPDATE nomenclature_change_inputs
        SET note_es=''
        WHERE note_es IS NULL;

        UPDATE nomenclature_change_inputs
        SET note_fr=''
        WHERE note_fr IS NULL;

        UPDATE nomenclature_change_inputs
        SET internal_note=''
        WHERE internal_note IS NULL;
      SQL
    )
  end
end
