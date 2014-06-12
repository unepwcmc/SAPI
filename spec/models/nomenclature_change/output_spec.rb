require 'spec_helper'

describe NomenclatureChange::Output do
  describe :validate do
    context "when nomenclature change not specified" do
      let(:output){
        build(:nomenclature_change_output, :nomenclature_change_id => nil)
      }
      specify { expect(output).not_to be_valid }
    end
    context "when taxon concept not specified and new_full_name not specified" do
      let(:output){
        build(
          :nomenclature_change_output, :taxon_concept_id => nil,
          :new_full_name => nil
        )
      }
      specify { expect(output).not_to be_valid }
    end
  end
end
