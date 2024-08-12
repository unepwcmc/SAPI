# == Schema Information
#
# Table name: nomenclature_change_reassignments
#
#  id                           :integer          not null, primary key
#  internal_note                :text
#  note_en                      :text
#  note_es                      :text
#  note_fr                      :text
#  reassignable_type            :string(255)
#  type                         :string(255)      not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  created_by_id                :integer          not null
#  nomenclature_change_input_id :integer          not null
#  reassignable_id              :integer
#  updated_by_id                :integer          not null
#
# Foreign Keys
#
#  nomenclature_change_reassignments_created_by_id_fk  (created_by_id => users.id)
#  nomenclature_change_reassignments_input_id_fk       (nomenclature_change_input_id => nomenclature_change_inputs.id)
#  nomenclature_change_reassignments_updated_by_id_fk  (updated_by_id => users.id)
#

require 'spec_helper'

describe NomenclatureChange::Reassignment do
  describe :validate do
    context "when input not specified" do
      let(:reassignment) {
        build(
          :nomenclature_change_reassignment,
          nomenclature_change_input_id: nil
        )
      }
      specify { expect(reassignment).not_to be_valid }
    end
    context "when reassignable_type not specified" do
      let(:reassignment) {
        build(
          :nomenclature_change_reassignment, reassignable_type: nil
        )
      }
      specify { expect(reassignment).not_to be_valid }
    end
  end
end
