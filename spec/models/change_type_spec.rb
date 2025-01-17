# == Schema Information
#
# Table name: change_types
#
#  id              :integer          not null, primary key
#  display_name_en :text             not null
#  display_name_es :text
#  display_name_fr :text
#  name            :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  designation_id  :integer          not null
#
# Indexes
#
#  index_change_types_on_designation_id                      (designation_id)
#  index_change_types_on_designation_id_and_display_name_en  (designation_id,display_name_en) UNIQUE
#  index_change_types_on_designation_id_and_name             (designation_id,name) UNIQUE
#  index_change_types_on_display_name_en_and_designation_id  (display_name_en,designation_id) UNIQUE
#  index_change_types_on_name_and_designation_id             (name,designation_id) UNIQUE
#
# Foreign Keys
#
#  change_types_designation_id_fk  (designation_id => designations.id)
#

require 'spec_helper'

describe ChangeType do
  describe :abbreviation do
    context 'change type with single word name' do
      let(:change_type) { create(:change_type, name: 'Word') }
      specify { expect(change_type.abbreviation).to eq('Wor') }
    end

    context 'change type with two words name' do
      let(:change_type) { create(:change_type, name: 'Word_Word') }
      specify { expect(change_type.abbreviation).to eq('Wor-Wor') }
    end
  end
end
