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
          :new_full_name => nil,
          :new_parent_id => nil,
          :new_rank_id => nil,
          :new_name_status => nil
        )
      }
      specify { expect(output).to have(1).errors_on(:new_full_name) }
      specify { expect(output).to have(1).errors_on(:new_parent_id) }
      specify { expect(output).to have(1).errors_on(:new_rank_id) }
      specify { expect(output).to have(1).errors_on(:new_name_status) }
    end
    context "when new taxon concept invalid" do
      let(:output){
        build(
          :nomenclature_change_output, :taxon_concept_id => nil,
          :new_full_name => 'xxx',
          :new_parent_id => create_cites_eu_species.id,
          :new_rank_id => species_rank.id,
          :new_name_status => nil
        )
      }
      specify { expect(output).to have(1).errors_on(:new_parent_id) }
    end
  end
end
