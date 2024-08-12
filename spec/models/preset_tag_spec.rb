# == Schema Information
#
# Table name: preset_tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  model      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe PresetTag do
  describe :create do
    context 'when valid' do
      let(:preset_tag) { build(:preset_tag, name: 'Test Tag', model: 'TaxonConcept') }
      specify { expect(preset_tag).to be_valid }
    end
    context 'when name missing' do
      let(:preset_tag) { build(:preset_tag, name: nil, model: 'TaxonConcept') }
      specify { expect(preset_tag).to be_invalid }
      specify { expect(preset_tag).to have(1).error_on(:name) }
    end
    context 'when model (type) incorrect' do
      let(:preset_tag) { build(:preset_tag, name: 'Test Tag', model: 'Nope') }
      specify { expect(preset_tag).to be_invalid }
      specify { expect(preset_tag).to have(1).error_on(:model) }
    end
  end
end
