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
end
