# == Schema Information
#
# Table name: events
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  designation_id :integer
#  effective_at   :datetime
#  published_at   :datetime
#  description    :text
#  url            :text
#  is_current     :boolean          default(FALSE), not null
#  type           :string(255)      default("Event"), not null
#

require 'spec_helper'

describe CitesCop do
  describe :create do
    context "when designation invalid" do
      let(:cites_cop){
        build(
          :cites_cop,
          :designation => eu
        )
      }
      specify { cites_cop.should be_invalid}
      specify { cites_cop.should have(1).error_on(:designation_id) }
    end
  end
end
