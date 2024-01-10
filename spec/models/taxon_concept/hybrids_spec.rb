require 'spec_helper'

describe TaxonConcept do
  before(:each) { hybrid_relationship_type }
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
    let(:hybrid) {
      create_cites_eu_species(
        name_status: 'H',
        author_year: 'Taxonomus 2013',
        taxon_name: create(:taxon_name, :scientific_name => 'Lolcatus lolcatus x lolatus')
      )
    }
    let!(:hybrid_rel) {
      create(:taxon_relationship,
        taxon_relationship_type: hybrid_relationship_type,
        taxon_concept_id: tc.id,
        other_taxon_concept_id: hybrid.id
      )
    }
    context "when new" do
      specify {
        tc.has_hybrids?.should be_truthy
      }
      specify {
        hybrid.is_hybrid?.should be_truthy
      }
      specify {
        hybrid.has_hybrid_parents?.should be_truthy
      }
      specify {
        hybrid.full_name.should == 'Lolcatus lolcatus x lolatus'
      }
    end
    context "when duplicate" do
      let(:duplicate) {
        hybrid.dup
      }
      specify {
        lambda do
          duplicate.save
        end.should change(TaxonConcept, :count).by(0)
      }
    end
    context "when duplicate but author name different" do
      let(:duplicate) {
        res = hybrid.dup
        res.author_year = 'Hemulen 2013'
        res
      }
      specify {
        lambda do
          duplicate.save
        end.should change(TaxonConcept, :count).by(1)
      }
    end
  end
end
