# == Schema Information
#
# Table name: nomenclature_change_inputs
#
#  id                     :integer          not null, primary key
#  nomenclature_change_id :integer          not null
#  taxon_concept_id       :integer          not null
#  note_en                :text
#  note_es                :text
#  note_fr                :text
#  internal_note          :text
#  created_by_id          :integer          not null
#  updated_by_id          :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

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
