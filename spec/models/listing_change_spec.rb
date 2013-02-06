require 'spec_helper'

describe ListingChange do
  context "validations" do
    describe :create do
      context "inclusion taxon concept does not exist" do
        let(:taxon_concept){ create(:taxon_concept) }
        let(:listing_change){
          build(
            :listing_change,
            :taxon_concept => taxon_concept,
            :inclusion_scientific_name => 'Abcd'
          )
        }
        specify{ listing_change.should have(1).error_on(:inclusion_scientific_name)}
      end
      context "inclusion taxon concept is lower rank" do
        let(:rank1){ create(:rank, :taxonomic_position => '1')}
        let(:rank2){ create(:rank, :taxonomic_position => '1.2')}
        let!(:inclusion){
          create(
            :taxon_concept,
            :rank => rank2,
            :taxon_name => create(:taxon_name, :scientific_name => 'Abc')
          )
        }
        let(:taxon_concept){ create(:taxon_concept, :rank => rank1) }
        let(:listing_change){
          build(
            :listing_change,
            :taxon_concept => taxon_concept,
            :inclusion_scientific_name => 'Abc'
          )
        }
        specify{listing_change.should have(1).error_on(:inclusion_taxon_concept_id)}
      end
      context "excluded taxon concept does not exist" do
        let(:designation){ create(:designation) }
        let(:exception_type){ create(:change_type, :designation_id => designation.id, :name => 'EXCEPTION') }
        let(:taxon_concept){ create(:taxon_concept) }
        let(:listing_change){
          build(
            :listing_change,
            :taxon_concept => taxon_concept,
            :exclusions_attributes => {
              '0' => {
                :exclusion_scientific_name => 'Abcd',
                :change_type_id => exception_type.id
              }
            }
          )
        }
        #specify{ listing_change.should have(1).error_on(:exclusion_scientific_name)}
      end
      context "inclusion taxon concept is lower rank" do
        let(:rank1){ create(:rank, :taxonomic_position => '1')}
        let(:rank2){ create(:rank, :taxonomic_position => '1.2')}
        let!(:inclusion){
          create(
            :taxon_concept,
            :rank => rank2,
            :taxon_name => create(:taxon_name, :scientific_name => 'Abc')
          )
        }
        let(:taxon_concept){ create(:taxon_concept, :rank => rank1) }
        let(:listing_change){
          build(
            :listing_change,
            :taxon_concept => taxon_concept,
            :inclusion_scientific_name => 'Abc'
          )
        }
        specify{listing_change.should have(1).error_on(:inclusion_taxon_concept_id)}
      end
      context "designation mismatch" do
        let(:designation1){ create(:designation)}
        let(:designation2){ create(:designation)}
        let(:listing_change){
          build(
            :listing_change,
            :species_listing => create(:species_listing, :designation => designation1),
            :change_type => create(:change_type, :designation => designation2)
          )
        }
        specify{listing_change.should have(1).error_on(:species_listing_id)}
      end
    end
  end
end