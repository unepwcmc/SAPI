require 'spec_helper'

describe NomenclatureChange::Input do
  describe :validate do
    context "when nomenclature change not specified" do
      let(:input){
        build(:nomenclature_change_input, :nomenclature_change_id => nil)
      }
      specify { expect(input).not_to be_valid }
    end
    context "when taxon concept not specified" do
      let(:input){
        build(:nomenclature_change_input, :taxon_concept_id => nil)
      }
      specify { expect(input).not_to be_valid }
    end
  end
end
