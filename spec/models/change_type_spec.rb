require 'spec_helper'

describe ChangeType do
  describe :abbreviation do
    context 'change type with single word name' do
      let(:change_type) { create(:change_type, name: 'Word') }
      specify { expect(change_type.abbreviation).to eq('Wor') }
    end

    context 'change type with two words name' do
      let(:change_type) { create(:change_type, name: 'Word_Word') }
      specify { expect(change_type.abbreviation).to eq('Wor-Wor') }
    end
  end
end
