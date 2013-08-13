# == Schema Information
#
# Table name: listing_changes
#
#  id                         :integer          not null, primary key
#  taxon_concept_id           :integer          not null
#  species_listing_id         :integer
#  change_type_id             :integer          not null
#  annotation_id              :integer
#  hash_annotation_id         :integer
#  effective_at               :datetime         default(2012-09-21 07:32:20 UTC), not null
#  is_current                 :boolean          default(FALSE), not null
#  parent_id                  :integer
#  inclusion_taxon_concept_id :integer
#  event_id                   :integer
#  source_id                  :integer
#  explicit_change            :boolean          default(TRUE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  import_row_id              :integer
#

require 'spec_helper'

describe ListingChange do
  context "validations" do
    describe :create do
      context "all fine with exception" do
        let(:designation){ create(:designation) }
        let!(:exception_type){ cites_exception }
        let(:taxon_concept){ create(:taxon_concept) }
        let(:excluded_taxon_concept){ create(:taxon_concept, :parent_id => taxon_concept) }
        let(:listing_change){
          create_cites_I_addition(
            :taxon_concept => taxon_concept,
            :excluded_taxon_concepts_ids => "#{excluded_taxon_concept.id}"
          )
        }
        specify{ listing_change.exclusions.size == 0 }
      end
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
