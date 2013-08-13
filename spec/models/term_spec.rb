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

describe Term do
  describe :destroy do
    context "when no dependent objects attached" do
      let(:term){ create(:term) }
      specify { term.destroy.should be_true }
    end
    context "when dependent objects attached" do
      let(:term){ create(:term) }
      #context "when EU opinion" do
      #  let!(:eu_opinion){ create(:eu_opinion, :term => term)}
      #  specify { term.destroy.should be_false }
      #end
      #context "when EU suspension" do
      #  let!(:eu_suspension){ create(:eu_suspension, :term => term)}
      #  specify { term.destroy.should be_false }
      #end
      context "when CITES suspension" do
        let!(:cites_suspension){ create(
          :cites_suspension,
          :terms => [term],
          :start_notification_id => create_cites_suspension_notification.id
        ) }
        specify { term.destroy.should be_false }
      end
      context "when CITES quota" do
        let!(:quota){ create(:quota, :terms => [term])}
        specify { term.destroy.should be_false }
      end
    end
  end
end
