# == Schema Information
#
# Table name: events
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  designation_id       :integer
#  description          :text
#  url                  :text
#  is_current           :boolean          default(FALSE), not null
#  type                 :string(255)      default("Event"), not null
#  effective_at         :datetime
#  published_at         :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  legacy_id            :integer
#  end_date             :datetime
#  subtype              :string(255)
#  updated_by_id        :integer
#  created_by_id        :integer
#  extended_description :text
#  multilingual_url     :text
#  elib_legacy_id       :integer
#

require 'spec_helper'

describe CitesCop do
  describe :create do
    context "when designation invalid" do
      let(:cites_cop) {
        build(
          :cites_cop,
          :designation => eu
        )
      }
      specify { expect(cites_cop).to be_invalid }
      specify { expect(cites_cop).to have(1).error_on(:designation_id) }
    end
    context "when effective_at is blank" do
      let(:cites_cop) {
        build(
          :cites_cop,
          :effective_at => nil
        )
      }
      specify { expect(cites_cop).to be_invalid }
      specify { expect(cites_cop).to have(1).error_on(:effective_at) }
    end
  end

  describe :destroy do
    let(:cites_cop) { create_cites_cop }
    context "when no dependent objects attached" do
      specify { expect(cites_cop.destroy).to be_truthy }
    end
    context "when dependent objects attached" do
      context "when listing changes" do
        let!(:listing_change) { create_cites_I_addition(:event => cites_cop) }
        specify { expect(cites_cop.destroy).to be_falsey }
      end
    end
  end
end
