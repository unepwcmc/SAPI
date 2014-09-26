# == Schema Information
#
# Table name: change_types
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  designation_id  :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  display_name_en :text             not null
#  display_name_es :text
#  display_name_fr :text
#

require 'spec_helper'

describe ChangeType do
  describe :abbreviation do
    context 'change type with single word name' do
      let(:change_type) { create(:change_type, :name => "Word") }
      specify { change_type.abbreviation.should == 'Wor' }
    end

    context 'change type with two words name' do
      let(:change_type) { create(:change_type, :name => "Word_Word") }
      specify { change_type.abbreviation.should == 'Wor-Wor' }
    end
  end
end
