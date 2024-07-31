# == Schema Information
#
# Table name: common_names
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  language_id   :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer
#  updated_by_id :integer
#

require 'spec_helper'

describe CommonName do
  context "Generating PDF" do
    describe :english_to_pdf do
      it "should print last word before the first word, separated by comma" do
        expect(CommonName.english_to_pdf("Grey Wolf")).to eq("Wolf, Grey")
      end
      it "should print the last word before the other words, separated by comma" do
        expect(CommonName.english_to_pdf("Northern Rock Mountain Wolf")).to eq("Wolf, Northern Rock Mountain")
      end
      it "should print the single word, if the common name is composed of only one word" do
        expect(CommonName.english_to_pdf("Wolf")).to eq("Wolf")
      end
    end
  end

  describe 'Validations' do
    # Use this context for the pre-defined languages
    context "Agave" do
      include_context "Agave"

      it 'Is valid with name and language id' do
        new_record = CommonName.new(
          name: 'Agave arizonique',
          language_id: @fr.id
        )

        expect(new_record).to be_valid
      end

      it 'Is valid with lots of non-ASCII PDF-safe characters' do
        new_record = CommonName.new(
          name: 'Sigríður O’Brian–Żądło’s agave',
          language_id: @en.id
        )

        expect(new_record).to be_valid
      end

      it 'Rejects cyrillic text in FR common name' do
        new_record = CommonName.new(
          name: 'Агава аризонская',
          language_id: @fr.id
        )

        expect(new_record.error_on(:name)).to contain_exactly(
          'in EN/FR/ES must be PDF-friendly'
        )
      end

      it 'Accepts cyrillic text in RU common name' do
        lang_ru = create(:language, :name => 'Russian', :iso_code1 => 'RU', :iso_code3 => 'RUS').id

        new_record = CommonName.new(
          name: 'Агава аризонская',
          language_id: lang_ru.id
        )

        expect(new_record).to be_valid
      end
    end
  end
end
