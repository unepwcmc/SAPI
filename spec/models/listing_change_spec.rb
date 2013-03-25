# == Schema Information
#
# Table name: listing_changes
#
#  id                         :integer          not null, primary key
#  taxon_concept_id           :integer          not null
#  species_listing_id         :integer
#  change_type_id             :integer          not null
#  effective_at               :datetime         default(2012-09-21 07:32:20 UTC), not null
#  is_current                 :boolean          default(FALSE), not null
#  annotation_id              :integer
#  parent_id                  :integer
#  inclusion_taxon_concept_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  hash_annotation_id         :integer
#

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
                :scientific_name => 'Abcd',
                :change_type_id => exception_type.id
              }
            }
          )
        }
        specify{ listing_change.exclusions.first.should have(1).error_on(:scientific_name)}
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
      context "species listing designation mismatch" do
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
      context "event designation mismatch" do
        let(:designation1){ create(:designation)}
        let(:designation2){ create(:designation)}
        let(:listing_change){
          build(
            :listing_change,
            :event_id => create(:event, :designation => designation1).id,
            :change_type => create(:change_type, :designation => designation2)
          )
        }
        specify{listing_change.should have(1).error_on(:event_id)}
      end
    end
  end
  describe :effective_at_formatted do
    let(:listing_change){ create_cites_I_addition(:effective_at => '2012-05-10') }
    specify {listing_change.effective_at_formatted.should == '10/05/2012' }
  end
end
