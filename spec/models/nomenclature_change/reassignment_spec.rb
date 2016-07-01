# == Schema Information
#
# Table name: nomenclature_change_reassignments
#
#  id                           :integer          not null, primary key
#  nomenclature_change_input_id :integer          not null
#  type                         :string(255)      not null
#  reassignable_type            :string(255)
#  reassignable_id              :integer
#  note_en                      :text
#  note_es                      :text
#  note_fr                      :text
#  internal_note                :text
#  created_by_id                :integer          not null
#  updated_by_id                :integer          not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

require 'spec_helper'

describe NomenclatureChange::Reassignment do
  describe :validate do
    context "when input not specified" do
      let(:reassignment) {
        build(
          :nomenclature_change_reassignment,
          :nomenclature_change_input_id => nil
        )
      }
      specify { expect(reassignment).not_to be_valid }
    end
    context "when reassignable_type not specified" do
      let(:reassignment) {
        build(
          :nomenclature_change_reassignment, :reassignable_type => nil
        )
      }
      specify { expect(reassignment).not_to be_valid }
    end
  end
end
