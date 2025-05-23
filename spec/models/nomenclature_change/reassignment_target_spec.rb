require 'spec_helper'

describe NomenclatureChange::ReassignmentTarget do
  describe :validate do
    context 'when reassignment not specified' do
      let(:reassignment_target) do
        build(
          :nomenclature_change_reassignment_target,
          nomenclature_change_reassignment_id: nil
        )
      end
      specify { expect(reassignment_target).not_to be_valid }
    end
    context 'when output not specified' do
      let(:reassignment_target) do
        build(
          :nomenclature_change_reassignment_target,
          nomenclature_change_output_id: nil
        )
      end
      specify { expect(reassignment_target).not_to be_valid }
    end
  end
end
