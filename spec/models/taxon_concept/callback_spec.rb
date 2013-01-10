require 'spec_helper'

describe TaxonConcept do
  context "before validate" do
    let(:cites){ Designation.find_by_name('CITES') }
    let(:kingdom){ Rank.find_by_name('KINGDOM') }
    let(:phylum){ Rank.find_by_name('PHYLUM') }

    let(:kingdom_tc){
      create(
        :taxon_concept,
        :designation_id => cites.id,
        :rank_id => kingdom.id,
        :taxonomic_position => '1'
      )
    }

    context "taxonomic position not given for fixed order rank" do
      let(:tc){
        create(
          :taxon_concept,
          :designation_id => cites.id,
          :rank_id => phylum.id,
          :parent_id => kingdom_tc.id,
          :taxonomic_position => nil
        )
      }
      specify{ tc.taxonomic_position.should == '1.1' }
    end
    context "taxonomic position given for fixed order rank" do
      let(:tc){
        create(
          :taxon_concept,
          :designation_id => cites.id,
          :rank_id => phylum.id,
          :parent_id => kingdom_tc.id,
          :taxonomic_position => '1.2'
        )
      }
      specify{ tc.taxonomic_position.should == '1.2' }
    end
    context "taxonomic position not given for fixed order root rank" do
      let(:tc){
        create(
          :taxon_concept,
          :designation_id => cites.id,
          :rank_id => kingdom.id,
          :taxonomic_position => nil
        )
      }
      specify{ tc.taxonomic_position.should == '3' } # because Plantae is 2
    end
  end
end
