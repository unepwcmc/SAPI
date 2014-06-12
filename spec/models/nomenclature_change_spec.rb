require 'spec_helper'

describe NomenclatureChange do
  describe :validate do
    context "when status not specified" do
      let(:nomenclature_change){
        build(:nomenclature_change, :status => nil)
      }
      specify { expect(nomenclature_change).not_to be_valid }
    end
  end
end