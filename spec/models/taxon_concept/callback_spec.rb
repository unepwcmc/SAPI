require 'spec_helper'

describe TaxonConcept do
  context "before validate" do
    let(:kingdom_tc){
      create_cites_eu_kingdom(
        :taxonomic_position => '1'
      )
    }

    context "taxonomic position not given for fixed order rank" do
      let(:tc){
        create_cites_eu_phylum(
          :parent_id => kingdom_tc.id,
          :taxonomic_position => nil
        )
      }
      specify{ tc.taxonomic_position.should == '1.1' }
    end
    context "taxonomic position given for fixed order rank" do
      let(:tc){
        create_cites_eu_phylum(
          :parent_id => kingdom_tc.id,
          :taxonomic_position => '1.2'
        )
      }
      specify{ tc.taxonomic_position.should == '1.2' }
    end
    context "taxonomic position not given for fixed order root rank" do
      let(:tc){
        create_cites_eu_kingdom(
          :taxonomic_position => nil
        )
      }
      specify{ tc.taxonomic_position.should == '1' }
    end
  end

  context "before create" do
    let(:genus_tc) {
      create_cites_eu_genus(
        :data => {:class_name => "Derp"}
      )
    }
    context "Data should be copied when creating a children taxon concept" do
      let(:tc) {
        create_cites_eu_species(
          :parent_id => genus_tc.id
        )
      }
      specify { tc.data["class_name"].should == genus_tc.data["class_name"] }
      specify { tc.data["rank_name"].should == Rank::SPECIES }
    end
  end
end
