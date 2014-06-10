require 'spec_helper'

describe TaxonConcept do
  before(:all) do
    @has_trade_name = create(
      :taxon_relationship_type,
      :name => TaxonRelationshipType::HAS_TRADE_NAME,
      :is_intertaxonomic => false,
      :is_bidirectional => false
    )
  end
  describe :create do
    let(:parent){
      create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
      )
    }
    let!(:tc){
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolatus')
      )
    }
    let(:trade_name){
      build_cites_eu_species(
        :name_status => 'T',
        :author_year => 'Taxonomus 2014',
        :accepted_scientific_name => tc.full_name,
        :full_name => 'Lolcatus lolus'
      )
    }
    context "when new" do
      specify {
        lambda do
          trade_name.save
        end.should change(TaxonConcept, :count).by(1)
      }
      pending {
        lambda do
          trade_name.save
        end.should change(TaxonRelationship, :count).by(1)
      }
      pending {
        trade_name.save
        tc.has_trade_names?.should be_true
      }
      specify {
        trade_name.save
        trade_name.is_trade_name?.should be_true
      }
    end
    context "when duplicate" do
      let(:duplicate){
        trade_name.dup
      }
      specify {
        lambda do
          trade_name.save
          duplicate.save
        end.should change(TaxonConcept, :count).by(1)
      }
      pending {
        lambda do
          trade_name.save
          duplicate.save
        end.should change(TaxonRelationship, :count).by(2)
      }
    end
    context "when duplicate but author name different" do
      let(:duplicate){
        res = trade_name.dup
        res.author_year = 'Hemulen 2013'
        res
      }
      specify {
        lambda do
          trade_name.save
          duplicate.save
        end.should change(TaxonConcept, :count).by(2)
      }
      specify {
        trade_name.save
        trade_name.full_name.should == 'Lolcatus lolus'
      }
    end
    context "when has accepted parent" do
      before(:each) do
        @subspecies = create_cites_eu_subspecies(
          :parent => tc,
          :taxon_name => create(:taxon_name, :scientific_name => 'perfidius')
        )
        @trade_name = create_cites_eu_subspecies(
          :parent_id => tc.id,
          :name_status => 'T',
          :author_year => 'Taxonomus 2013',
          :full_name => 'Lolcatus lolus furiatus'
        )
        create(
          :taxon_relationship,
          :taxon_relationship_type => @has_trade_name,
          :taxon_concept => @subspecies,
          :other_taxon_concept => @trade_name
        )
      end
      # should not modify a trade_name's full name when saving
      specify { @trade_name.full_name.should == 'Lolcatus lolus furiatus' }
      context "overnight calculations" do
        before(:each) do
          Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        end
        # should not modify a trade_name's full name overnight
        specify { @trade_name.reload.full_name.should == 'Lolcatus lolus furiatus' }
        # should not list trade_name as subspecies of accepted species
        specify { MTaxonConcept.find(tc.id).subspecies_not_listed_ary.should_not include(@trade_name.full_name) }
      end
    end
  end
end