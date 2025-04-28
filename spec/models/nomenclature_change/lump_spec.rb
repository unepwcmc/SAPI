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

describe NomenclatureChange::Lump do
  describe :validate do
    context 'when required inputs missing' do
      context 'when inputs' do
        let(:lump) do
          build(
            :nomenclature_change_lump, status: NomenclatureChange::Lump::INPUTS
          )
        end
        specify { expect(lump).to have(1).errors_on(:inputs) }
      end
      context 'when submitting' do
        let(:lump) do
          build(
            :nomenclature_change_lump, status: NomenclatureChange::Lump::SUBMITTED
          )
        end
        specify { expect(lump).to have(1).errors_on(:inputs) }
      end
    end
    context 'when required outputs missing' do
      context 'when outputs' do
        let(:lump) do
          build(
            :nomenclature_change_lump, status: NomenclatureChange::Lump::OUTPUTS
          )
        end
        specify { expect(lump).to have(1).errors_on(:output) }
      end
      context 'when submitting' do
        let(:lump) do
          build(
            :nomenclature_change_lump, status: NomenclatureChange::Lump::SUBMITTED
          )
        end
        specify { expect(lump).to have(1).errors_on(:output) }
      end
      context 'when only 1 input' do
        let(:lump) do
          build(
            :nomenclature_change_lump, status: NomenclatureChange::Lump::SUBMITTED,
            inputs_attributes: { 0 => { taxon_concept_id: create_cites_eu_subspecies.id } }
          )
        end
        specify { expect(lump.errors_on(:inputs).size).to eq(1) }
      end
    end
  end
  describe :new_output_rank do
    let(:lump) do
      build(
        :nomenclature_change_lump,
        inputs_attributes: {
          0 => { taxon_concept_id: create_cites_eu_species.id },
          1 => { taxon_concept_id: create_cites_eu_subspecies.id }
        },
        status: NomenclatureChange::Lump::INPUTS
      )
    end
    specify { expect(lump.new_output_rank.name).to eq(Rank::SPECIES) }
  end
end
