# == Schema Information
#
# Table name: nomenclature_change_inputs
#
#  id                     :integer          not null, primary key
#  internal_note          :text             default("")
#  note_en                :text             default("")
#  note_es                :text             default("")
#  note_fr                :text             default("")
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  created_by_id          :integer          not null
#  nomenclature_change_id :integer          not null
#  taxon_concept_id       :integer          not null
#  updated_by_id          :integer          not null
#
# Indexes
#
#  index_nomenclature_change_inputs_on_created_by_id           (created_by_id)
#  index_nomenclature_change_inputs_on_nomenclature_change_id  (nomenclature_change_id)
#  index_nomenclature_change_inputs_on_taxon_concept_id        (taxon_concept_id)
#  index_nomenclature_change_inputs_on_updated_by_id           (updated_by_id)
#
# Foreign Keys
#
#  nomenclature_change_inputs_created_by_id_fk           (created_by_id => users.id)
#  nomenclature_change_inputs_nomenclature_change_id_fk  (nomenclature_change_id => nomenclature_changes.id)
#  nomenclature_change_inputs_taxon_concept_id_fk        (taxon_concept_id => taxon_concepts.id)
#  nomenclature_change_inputs_updated_by_id_fk           (updated_by_id => users.id)
#

require 'spec_helper'

describe NomenclatureChange::Input do
  describe :validate do
    context 'when nomenclature change not specified' do
      let(:input) do
        build(:nomenclature_change_input, nomenclature_change_id: nil)
      end
      specify { expect(input).not_to be_valid }
    end
    context 'when taxon concept not specified' do
      let(:input) do
        build(:nomenclature_change_input, taxon_concept_id: nil)
      end
      specify { expect(input).not_to be_valid }
    end
  end
end
