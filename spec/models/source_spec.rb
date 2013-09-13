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

describe Source do
  describe :destroy do
    context "when no dependent objects attached" do
      let(:source){ create(:source) }
      specify { source.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:source){ create(:source) }
      #context "when EU opinion" do
      #  let!(:eu_opinion){ create(:eu_opinion, :source => source)}
      #  specify { source.destroy.should be_false }
      #end
      #context "when EU suspension" do
      #  let!(:eu_suspension){ create(:eu_suspension, :source => source)}
      #  specify { source.destroy.should be_false }
      #end
      context "when CITES suspension" do
        let!(:cites_suspension){ create(
          :cites_suspension,
          :sources => [source],
          :start_notification_id => create_cites_suspension_notification.id
        ) }
        specify { source.destroy.should be_false }
      end
      context "when CITES quota" do
        let(:geo_entity) { create(:geo_entity) }
        let!(:quota){ create(:quota, :sources => [source], :geo_entity_id => geo_entity.id)}
        specify { source.destroy.should be_false }
      end
    end
  end
end
