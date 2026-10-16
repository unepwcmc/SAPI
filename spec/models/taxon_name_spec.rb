require 'spec_helper'

describe TaxonName do
  describe 'Validations' do
    it 'strips leading and trailing whitespace' do
      new_record = build(:taxon_name, scientific_name: " Foobaridae\t")

      expect(new_record.scientific_name).to eq('Foobaridae')
    end
  end
end
