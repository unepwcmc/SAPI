require 'spec_helper'

describe TaxonConcept do
  before(:each) { synonym_relationship_type }
  describe :create do
    let(:parent) {
      create_cites_eu_genus(
        :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
      )
    }
    let!(:tc) {
      create_cites_eu_species(
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolatus')
      )
    }
    let(:synonym) {
      create_cites_eu_species(
        :name_status => 'S',
        :author_year => 'Taxonomus 2013',
        taxon_name: create(:taxon_name, scientific_name: 'Lolcatus lolus')
      )
    }
    let!(:synonym_rel) {
      create(:taxon_relationship,
        taxon_relationship_type: synonym_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: synonym.id
      )
    }
    context "when new" do
      specify {
        tc.has_synonyms?.should be_truthy
      }
      specify {
        synonym.is_synonym?.should be_truthy
      }
      specify {
        synonym.has_accepted_names?.should be_truthy
      }
      specify {
        synonym.full_name.should == 'Lolcatus lolus'
      }
    end
    context "when duplicate" do
      let(:duplicate) {
        synonym.dup
      }
      specify {
        lambda do
          duplicate.save
        end.should change(TaxonConcept, :count).by(0)
      }
    end
    context "when duplicate but author name different" do
      let(:duplicate) {
        res = synonym.dup
        res.author_year = 'Hemulen 2013'
        res
      }
      specify {
        lambda do
          duplicate.save
        end.should change(TaxonConcept, :count).by(1)
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
          scientific_name: 'Lolcatus lolus furiatus'
        )
        create(
          :taxon_relationship,
          :taxon_relationship_type => synonym_relationship_type,
          :taxon_concept => @subspecies,
          :other_taxon_concept => @synonym
        )
      end
      # should not modify a synonym's full name when saving
      specify { @synonym.full_name.should == 'Lolcatus lolus furiatus' }
      context "overnight calculations" do
        before(:each) do
          Sapi::StoredProcedures.rebuild_cites_taxonomy_and_listings
        end
        # should not modify a synonym's full name overnight
        specify { @synonym.reload.full_name.should == 'Lolcatus lolus furiatus' }
      end
    end
  end
end
