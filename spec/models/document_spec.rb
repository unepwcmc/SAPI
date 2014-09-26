# == Schema Information
#
# Table name: documents
#
#  id            :integer          not null, primary key
#  title         :text             not null
#  filename      :text             not null
#  date          :date             not null
#  type          :string(255)      not null
#  is_public     :boolean          default(FALSE), not null
#  event_id      :integer
#  language_id   :integer
#  legacy_id     :integer
#  created_by_id :integer
#  updated_by_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  number        :string(255)
#

require 'spec_helper'

describe Document do

  describe :create do
    context "when date is blank" do
      let(:document){
        build(
          :document,
          :date => nil
        )
      }
      specify { expect(document).to be_invalid }
      specify { expect(document).to have(1).error_on(:date) }
    end
    context "setting title from filename" do
      let(:document){ create(:document) }
      specify{ expect(document.title).to eq('Annual report upload exporter') }
    end
  end
end
