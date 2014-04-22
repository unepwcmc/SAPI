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

describe Unit do
  describe :destroy do
    context "when no dependent objects attached" do
      let(:unit){ create(:unit) }
      specify { unit.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:unit){ create(:unit) }
      context "when quotas" do
        let(:geo_entity){ create(:geo_entity) }
        let!(:quota){ create(:quota, :unit => unit, :geo_entity_id => geo_entity.id)}
        specify { unit.destroy.should be_false }
      end
      context "when shipments" do
        before(:each){ create(:shipment, :unit => unit) }
        specify { unit.destroy.should be_false }
      end
    end
  end
end
