require 'spec_helper'

describe NomenclatureChange do
  describe :validate do
    context 'when status not specified' do
      let(:nomenclature_change) do
        build(:nomenclature_change, status: nil)
      end
      specify { expect(nomenclature_change).not_to be_valid }
    end
    context 'when previous status=submitted' do
      let(:nomenclature_change) do
        nc = create(:nomenclature_change, status: NomenclatureChange::SUBMITTED)
        nc.status = NomenclatureChange::NEW
        nc
      end
      specify { expect(nomenclature_change).not_to be_valid }
    end
    context 'when previous status=closed' do
      let(:nomenclature_change) do
        nc = create(:nomenclature_change, status: NomenclatureChange::CLOSED)
        nc.status = NomenclatureChange::SUBMITTED
        nc
      end
      specify { expect(nomenclature_change).not_to be_valid }
    end
  end
  describe :submitting? do
    context 'when new object with status=submitted' do
      let(:nomenclature_change) do
        build(:nomenclature_change, status: NomenclatureChange::SUBMITTED)
      end
      specify { expect(nomenclature_change).to be_submitting }
    end
    context 'when updating object with status new -> submitted' do
      let(:nomenclature_change) do
        nc = create(:nomenclature_change, status: NomenclatureChange::NEW)
        nc.status = NomenclatureChange::SUBMITTED
        nc
      end
      specify { expect(nomenclature_change).to be_submitting }
    end
    context 'when updating object with status submitted -> closed' do
      let(:nomenclature_change) do
        nc = create(:nomenclature_change, status: NomenclatureChange::SUBMITTED)
        nc.status = NomenclatureChange::CLOSED
        nc
      end
      specify { expect(nomenclature_change).not_to be_submitting }
    end
    context 'when updating object with status closed -> submitted' do
      let(:nomenclature_change) do
        nc = create(:nomenclature_change, status: NomenclatureChange::CLOSED)
        nc.status = NomenclatureChange::SUBMITTED
        nc
      end
      specify { expect(nomenclature_change).not_to be_submitting }
    end
  end
end
