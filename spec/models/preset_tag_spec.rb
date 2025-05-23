require 'spec_helper'

describe PresetTag do
  describe :create do
    context 'when valid' do
      let(:preset_tag) { build(:preset_tag, name: 'Test Tag', model: 'TaxonConcept') }
      specify { expect(preset_tag).to be_valid }
    end
    context 'when name missing' do
      let(:preset_tag) { build(:preset_tag, name: nil, model: 'TaxonConcept') }
      specify { expect(preset_tag).not_to be_valid }
      specify { expect(preset_tag).to have(1).error_on(:name) }
    end
    context 'when model (type) incorrect' do
      let(:preset_tag) { build(:preset_tag, name: 'Test Tag', model: 'Nope') }
      specify { expect(preset_tag).not_to be_valid }
      specify { expect(preset_tag).to have(1).error_on(:model) }
    end
  end
end
