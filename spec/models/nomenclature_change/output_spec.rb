# == Schema Information
#
# Table name: nomenclature_change_outputs
#
#  id                     :integer          not null, primary key
#  nomenclature_change_id :integer          not null
#  taxon_concept_id       :integer
#  new_taxon_concept_id   :integer
#  new_parent_id          :integer
#  new_rank_id            :integer
#  new_scientific_name    :string(255)
#  new_author_year        :string(255)
#  new_name_status        :string(255)
#  note_en                :text
#  note_es                :text
#  note_fr                :text
#  internal_note          :text
#  created_by_id          :integer          not null
#  updated_by_id          :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_primary_output      :boolean          default(TRUE)
#  parent_id              :integer
#  rank_id                :integer
#  scientific_name        :string(255)
#  author_year            :string(255)
#  name_status            :string(255)
#

require 'spec_helper'

describe NomenclatureChange::Output do
  before(:each){ cites_eu }
  describe :validate do
    context "when nomenclature change not specified" do
      let(:output){
        build(:nomenclature_change_output, :nomenclature_change_id => nil)
      }
      specify { expect(output).not_to be_valid }
    end
    context "when taxon concept not specified and new taxon concept attributes not specified" do
      let(:output){
        build(
          :nomenclature_change_output, :taxon_concept_id => nil,
          :new_scientific_name => nil,
          :new_parent_id => nil,
          :new_rank_id => nil,
          :new_name_status => nil
        )
      }
      specify { expect(output).to have(1).errors_on(:new_scientific_name) }
      specify { expect(output).to have(1).errors_on(:new_parent_id) }
      specify { expect(output).to have(1).errors_on(:new_rank_id) }
      specify { expect(output).to have(1).errors_on(:new_name_status) }
    end
    context "when new taxon concept invalid" do
      let(:output){
        build(
          :nomenclature_change_output, :taxon_concept_id => nil,
          :new_scientific_name => 'xxx',
          :new_parent_id => create_cites_eu_species.id,
          :new_rank_id => species_rank.id,
          :new_name_status => 'A'
        )
      }
      specify { expect(output).to have(1).error_on(:new_parent_id) }
    end
    context "when taxon concept specified" do
      let(:tc){ create_cites_eu_species }
      let(:output){
        create(:nomenclature_change_output, :taxon_concept_id => tc.id)
      }
      specify{ expect(output.parent_id).to eq(tc.parent_id) }
      specify{ expect(output.rank_id).to eq(tc.rank_id) }
      specify{ expect(output.scientific_name).to eq(tc.full_name) }
      specify{ expect(output.author_year).to eq(tc.author_year) }
      specify{ expect(output.name_status).to eq(tc.name_status) }
    end
  end
end
