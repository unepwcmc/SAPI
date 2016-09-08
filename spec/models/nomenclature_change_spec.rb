# == Schema Information
#
# Table name: nomenclature_changes
#
#  id            :integer          not null, primary key
#  event_id      :integer
#  type          :string(255)      not null
#  status        :string(255)      not null
#  created_by_id :integer          not null
#  updated_by_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe NomenclatureChange do
  describe :validate do
    context "when status not specified" do
      let(:nomenclature_change) {
        build(:nomenclature_change, :status => nil)
      }
      specify { expect(nomenclature_change).not_to be_valid }
    end
    context "when previous status=submitted" do
      let(:nomenclature_change) {
        nc = create(:nomenclature_change, :status => NomenclatureChange::SUBMITTED)
        nc.status = NomenclatureChange::NEW
        nc
      }
      specify { expect(nomenclature_change).not_to be_valid }
    end
    context "when previous status=closed" do
      let(:nomenclature_change) {
        nc = create(:nomenclature_change, :status => NomenclatureChange::CLOSED)
        nc.status = NomenclatureChange::SUBMITTED
        nc
      }
      specify { expect(nomenclature_change).not_to be_valid }
    end
  end
  describe :submitting? do
    context "when new object with status=submitted" do
      let(:nomenclature_change) {
        build(:nomenclature_change, :status => NomenclatureChange::SUBMITTED)
      }
      specify { expect(nomenclature_change).to be_submitting }
    end
    context "when updating object with status new -> submitted" do
      let(:nomenclature_change) {
        nc = create(:nomenclature_change, :status => NomenclatureChange::NEW)
        nc.status = NomenclatureChange::SUBMITTED
        nc
      }
      specify { expect(nomenclature_change).to be_submitting }
    end
    context "when updating object with status submitted -> closed" do
      let(:nomenclature_change) {
        nc = create(:nomenclature_change, :status => NomenclatureChange::SUBMITTED)
        nc.status = NomenclatureChange::CLOSED
        nc
      }
      specify { expect(nomenclature_change).not_to be_submitting }
    end
    context "when updating object with status closed -> submitted" do
      let(:nomenclature_change) {
        nc = create(:nomenclature_change, :status => NomenclatureChange::CLOSED)
        nc.status = NomenclatureChange::SUBMITTED
        nc
      }
      specify { expect(nomenclature_change).not_to be_submitting }
    end
  end
end
