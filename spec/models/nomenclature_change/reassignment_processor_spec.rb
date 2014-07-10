require 'spec_helper'

describe NomenclatureChange::ReassignmentProcessor do
  describe :run do
    let(:input_species){ create_cites_eu_species }
    let!(:split){
      s = create(:nomenclature_change_split)
      s.update_attributes(
        :input_attributes => {:taxon_concept_id => input_species.id},
        :status => NomenclatureChange::Split::INPUTS
      )
      s
    }
    let(:input){ split.input }
    let(:output_species){ create_cites_eu_species }
    let(:output){
      create(
        :nomenclature_change_output, :nomenclature_change => split,
        :taxon_concept_id => output_species.id
      )
    }
    let(:processor){
      NomenclatureChange::ReassignmentProcessor.new(input, output)
    }

    context "when children" do
      let(:input_species_child){
        create_cites_eu_subspecies(:parent => input_species)
      }
      let(:reassignment){
        create(:nomenclature_change_parent_reassignment,
          :input => input,
          :reassignable_id => input_species_child.id
        )
      }
      let!(:reassignment_target){
        create(:nomenclature_change_reassignment_target,
          :reassignment => reassignment,
          :output => output
        )
      }
      before(:each) do
        processor.run
      end
      specify{ expect(input_species_child.reload.parent).to eq(output_species) }
      specify{ expect(input_species.children.count).to eq(0) }
    end
    context "when names" do
      let(:input_species_synonym){
        create_cites_eu_species
      }
      let(:input_species_synonym_rel){
        create(:taxon_relationship,
          :taxon_relationship_type_id => synonym_relationship_type.id,
          :taxon_concept => input_species,
          :other_taxon_concept => input_species_synonym
        )
      }
      let(:reassignment){
        create(:nomenclature_change_name_reassignment,
          :input => input,
          :reassignable_id => input_species_synonym_rel.id
        )
      }
      let!(:reassignment_target){
        create(:nomenclature_change_reassignment_target,
          :reassignment => reassignment,
          :output => output
        )
      }
      before(:each) do
        processor.run
      end
      specify{ expect(output_species.synonyms).to include(input_species_synonym) }
    end
    context "when listing changes" do
      let!(:input_species_listing){
        create_cites_I_addition(:taxon_concept => input_species)
        create_cites_II_addition(:taxon_concept => input_species)
      }
      let(:reassignment){
        create(:nomenclature_change_legislation_reassignment,
          :input => input,
          :reassignable_type => 'ListingChange'
        )
      }
      let!(:reassignment_target){
        create(:nomenclature_change_reassignment_target,
          :reassignment => reassignment,
          :output => output
        )
      }
      before(:each) do
        processor.run
      end
      specify{ expect(output_species.listing_changes.count).to eq(2) }
      specify{ expect(input_species.listing_changes).to be_empty }
    end
    context "when common names" do
      let!(:input_species_common_name){
        create(:taxon_common, :taxon_concept => input_species)
      }
      let(:reassignment){
        create(:nomenclature_change_reassignment,
          :input => input,
          :reassignable_type => 'TaxonCommon'
        )
      }
      let!(:reassignment_target){
        create(:nomenclature_change_reassignment_target,
          :reassignment => reassignment,
          :output => output
        )
      }
      before(:each) do
        processor.run
      end
      specify{ expect(output_species.common_names.count).to eq(1) }
    end
  end
end