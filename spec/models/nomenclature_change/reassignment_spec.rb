require 'spec_helper'

describe NomenclatureChange::Reassignment do
  describe :validate do
    context 'when input not specified' do
      let(:reassignment) do
        build(
          :nomenclature_change_reassignment,
          nomenclature_change_input_id: nil
        )
      end
      specify { expect(reassignment).not_to be_valid }
    end
    context 'when reassignable_type not specified' do
      let(:reassignment) do
        build(
          :nomenclature_change_reassignment, reassignable_type: nil
        )
      end
      specify { expect(reassignment).not_to be_valid }
    end
  end
end
