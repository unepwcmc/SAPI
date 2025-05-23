require 'spec_helper'

describe Event do
  describe :create do
    context 'when valid' do
      let(:event) { build(:event, name: 'CoPX') }
      specify { expect(event).to be_valid }
    end
    context 'when name missing' do
      let(:event) { build(:event, name: nil) }
      specify { expect(event).not_to be_valid }
      specify { expect(event).to have(1).error_on(:name) }
    end
    context 'when name duplicated' do
      let!(:event1) { create(:event) }
      let(:event2) { build(:event, name: event1.name) }
      specify { expect(event2).not_to be_valid }
      specify { expect(event2).to have(1).error_on(:name) }
    end
    context 'when url invalid' do
      let(:event) { build(:event, url: 'www.google.com') }
      specify { expect(event).not_to be_valid }
      specify { expect(event).to have(1).error_on(:url) }
    end
  end

  describe :effective_at_formatted do
    let(:event) { create(:event, effective_at: '2012-05-10') }
    specify { expect(event.effective_at_formatted).to eq('10/05/2012') }
  end
end
