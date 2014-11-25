require 'spec_helper'

describe NomenclatureChange::OutputReassignment do
  describe :validate do
    context "when output not specified" do
      let(:reassignment){
        build(
          :nomenclature_change_output_reassignment,
          :nomenclature_change_output_id => nil
        )
      }
      specify { expect(reassignment).not_to be_valid }
    end
    context "when reassignable_type not specified" do
      let(:reassignment){
        build(
          :nomenclature_change_output_reassignment, :reassignable_type => nil
        )
      }
      specify { expect(reassignment).not_to be_valid }
    end
  end
end