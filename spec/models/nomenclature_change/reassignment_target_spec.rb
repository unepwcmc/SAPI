# == Schema Information
#
# Table name: nomenclature_change_reassignment_targets
#
#  id                                  :integer          not null, primary key
#  nomenclature_change_reassignment_id :integer          not null
#  nomenclature_change_output_id       :integer          not null
#  created_by_id                       :integer          not null
#  updated_by_id                       :integer          not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#

require 'spec_helper'

describe NomenclatureChange::ReassignmentTarget do
  describe :validate do
    context "when reassignment not specified" do
      let(:reassignment_target) {
        build(
          :nomenclature_change_reassignment_target,
          :nomenclature_change_reassignment_id => nil
        )
      }
      specify { expect(reassignment_target).not_to be_valid }
    end
    context "when output not specified" do
      let(:reassignment_target) {
        build(
          :nomenclature_change_reassignment_target,
          :nomenclature_change_output_id => nil
        )
      }
      specify { expect(reassignment_target).not_to be_valid }
    end
  end
end
