require 'spec_helper'

describe NomenclatureChange::Split::TransformationProcessor do
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
    let(:processor){
      NomenclatureChange::Split::TransformationProcessor.new(output)
    }
    before(:each) do
      processor.run
    end
    context "when output is existing taxon" do
      let(:output_species){ create_cites_eu_species }
      let(:output){
        create(
          :nomenclature_change_output, :nomenclature_change => split,
          :taxon_concept_id => output_species.id
        )
      }
      specify{ expect(output.new_taxon_concept).to be_nil }
    end
    context "when output is new taxon" do
      let(:output_species_attrs){
        {
          :new_scientific_name => 'fatalus',
          :new_parent_id => create_cites_eu_genus(
            :taxon_name => create(:taxon_name, :scientific_name => 'Errorus')
          ).id,
          :new_rank_id => species_rank.id,
          :new_name_status => 'A'
        }
      }
      let(:output){
        create(
          :nomenclature_change_output,
          output_species_attrs.merge({:nomenclature_change => split})
        )
      }
      specify{ expect(output.new_taxon_concept.full_name).to eq('Errorus fatalus') }
    end
    context "when output is existing taxon with new status" do
      let(:output_species){ create_cites_eu_species(:name_status => 'S') }
      let(:output){
        create(
          :nomenclature_change_output, :nomenclature_change => split,
          :taxon_concept_id => output_species.id, :new_name_status => 'A'
        )
      }
      specify{ expect(output.new_taxon_concept).to be_nil }
      specify{ expect(output.taxon_concept.name_status).to eq('A') }
    end
    context "when output is existing taxon with new name" do
      let(:output_subspecies){
        create_cites_eu_subspecies(
          :taxon_name => create(:taxon_name, :scientific_name => 'fatalus'),
          :parent => create_cites_eu_species(
            :taxon_name => create(:taxon_name, :scientific_name => 'fatalus'),
            :parent => create_cites_eu_genus(
              :taxon_name => create(:taxon_name, :scientific_name => 'Errorus')
            )
          )
        )
      }
      let(:output_species_attrs){
        {
          :taxon_concept_id => output_subspecies.id,
          :new_scientific_name => 'lolcatus',
          :new_parent_id => create_cites_eu_genus(
            :taxon_name => create(:taxon_name, :scientific_name => 'Errorus')
          ).id,
          :new_rank_id => species_rank.id
        }
      }
      let(:output){
        create(
          :nomenclature_change_output,
          output_species_attrs.merge({
            :nomenclature_change => split, :taxon_concept_id => output_subspecies.id
          })
        )
      }
      specify{ expect(output.taxon_concept.full_name).to eq('Errorus fatalus fatalus') }
      pending{ expect(output.taxon_concept.name_status).to eq('S') }
      specify{ expect(output.new_taxon_concept.full_name).to eq('Errorus lolcatus') }
    end
  end
end