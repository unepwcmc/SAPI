# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  description          :text
#  effective_at         :datetime
#  end_date             :datetime
#  extended_description :text
#  is_current           :boolean          default(FALSE), not null
#  multilingual_url     :text
#  name                 :string(255)
#  private_url          :text
#  published_at         :datetime
#  subtype              :string(255)
#  type                 :string(255)      default("Event"), not null
#  url                  :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :integer
#  designation_id       :integer
#  elib_legacy_id       :integer
#  legacy_id            :integer
#  updated_by_id        :integer
#
# Indexes
#
#  index_events_on_created_by_id   (created_by_id)
#  index_events_on_designation_id  (designation_id)
#  index_events_on_name            (name) UNIQUE
#  index_events_on_updated_by_id   (updated_by_id)
#
# Foreign Keys
#
#  events_created_by_id_fk   (created_by_id => users.id)
#  events_designation_id_fk  (designation_id => designations.id)
#  events_updated_by_id_fk   (updated_by_id => users.id)
#

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
