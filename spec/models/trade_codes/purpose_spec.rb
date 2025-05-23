# == Schema Information
#
# Table name: trade_codes
#
#  id         :integer          not null, primary key
#  code       :string(255)      not null
#  type       :string(255)      not null
#  name_en    :string(255)      not null
#  name_es    :string(255)
#  name_fr    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Purpose do
  describe :destroy do
    context 'when no dependent objects attached' do
      let(:purpose) { create(:purpose) }
      specify { expect(purpose.destroy).to be_truthy }
    end
    context 'when dependent objects attached' do
      let(:purpose) { create(:purpose) }
      context 'when CITES suspension' do
        let!(:cites_suspension) do
          create(
            :cites_suspension,
            purposes: [ purpose ],
            start_notification_id: create_cites_suspension_notification.id
          )
        end
        specify { expect(purpose.destroy).to be_falsey }
      end
      context 'when shipments' do
        before(:each) { create(:shipment, purpose: purpose) }
        specify { expect(purpose.destroy).to be_falsey }
      end
    end
  end
end
