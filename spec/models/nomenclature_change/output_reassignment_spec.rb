# == Schema Information
#
# Table name: nomenclature_change_output_reassignments
#
#  id                            :integer          not null, primary key
#  nomenclature_change_output_id :integer          not null
#  type                          :string(255)      not null
#  reassignable_type             :string(255)
#  reassignable_id               :integer
#  note_en                       :text
#  created_by_id                 :integer          not null
#  updated_by_id                 :integer          not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  note_es                       :text
#  note_fr                       :text
#  internal_note                 :text
#

require 'spec_helper'

describe NomenclatureChange::OutputReassignment do
  describe :validate do
    context "when output not specified" do
      let(:reassignment) {
        build(
          :nomenclature_change_output_reassignment,
          :nomenclature_change_output_id => nil
        )
      }
      specify { expect(reassignment).not_to be_valid }
    end
    context "when reassignable_type not specified" do
      let(:reassignment) {
        build(
          :nomenclature_change_output_reassignment, :reassignable_type => nil
        )
      }
      specify { expect(reassignment).not_to be_valid }
    end
  end
end
