# == Schema Information
#
# Table name: nomenclature_changes
#
#  id            :integer          not null, primary key
#  status        :string(255)      not null
#  type          :string(255)      not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :integer          not null
#  event_id      :integer
#  updated_by_id :integer          not null
#
# Indexes
#
#  index_nomenclature_changes_on_created_by_id  (created_by_id)
#  index_nomenclature_changes_on_event_id       (event_id)
#  index_nomenclature_changes_on_updated_by_id  (updated_by_id)
#
# Foreign Keys
#
#  nomenclature_changes_created_by_id_fk  (created_by_id => users.id)
#  nomenclature_changes_event_id_fk       (event_id => events.id)
#  nomenclature_changes_updated_by_id_fk  (updated_by_id => users.id)
#

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
