require 'spec_helper'

describe TaxonConcept do
  before(:all) do
    @has_synonym = create(
      :taxon_relationship_type,
      :name => TaxonRelationshipType::HAS_SYNONYM,
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
    let(:synonym){
      build_cites_eu_species(
        :name_status => 'S',
        :author_year => 'Taxonomus 2013',
        :accepted_scientific_name => tc.full_name,
        :full_name => 'Lolcatus lolus'
      )
    }
    context "when new" do
      specify {
        lambda do
          synonym.save
        end.should change(TaxonConcept, :count).by(1)
      }
      pending {
        lambda do
          synonym.save
        end.should change(TaxonRelationship, :count).by(1)
      }
      pending {
        synonym.save
        tc.has_synonyms?.should be_true
      }
      specify {
        synonym.save
        synonym.is_synonym?.should be_true
      }
    end
    context "when duplicate" do
      let(:duplicate){
        synonym.dup
      }
      specify {
        lambda do
          synonym.save
          duplicate.save
        end.should change(TaxonConcept, :count).by(1)
      }
      pending {
        lambda do
          synonym.save
          duplicate.save
        end.should change(TaxonRelationship, :count).by(2)
      }
    end
    context "when duplicate but author name different" do
      let(:duplicate){
        res = synonym.dup
        res.author_year = 'Hemulen 2013'
        res
      }
      specify {
        lambda do
          synonym.save
          duplicate.save
        end.should change(TaxonConcept, :count).by(2)
      }
      specify {
        synonym.save
        synonym.full_name.should == 'Lolcatus lolus'
      }
    end
    context "when has accepted parent" do
      before(:each) do
        @subspecies = create_cites_eu_subspecies(
          :parent => tc,
          :taxon_name => create(:taxon_name, :scientific_name => 'perfidius')
        )
        @synonym = create_cites_eu_subspecies(
          :parent_id => tc.id,
          :name_status => 'S',
          :author_year => 'Taxonomus 2013',
          :full_name => 'Lolcatus lolus furiatus'
        )
        create(
          :taxon_relationship,
          :taxon_relationship_type => @has_synonym,
          :taxon_concept => @subspecies,
          :other_taxon_concept => @synonym
        )
      end
      # should not modify a synonym's full name when saving
      specify { @synonym.full_name.should == 'Lolcatus lolus furiatus' }
      context "overnight calculations" do
        before(:each) do
          cites
          eu
          cms_designation
          Sapi.rebuild
        end
        # should not modify a synonym's full name overnight
        specify { @synonym.reload.full_name.should == 'Lolcatus lolus furiatus' }
        # should not list synonym as subspecies of accepted species
        specify { MTaxonConcept.find(tc.id).subspecies_ary.should_not include(@synonym.full_name) }
      end
    end
  end
end