require 'spec_helper'

describe TaxonConcept do
  describe :create do
    let(:parent){
      create(
        :genus,
        :taxon_name => create(:taxon_name, :scientific_name => 'Lolcatus')
      )
    }
    let!(:tc){
      create(
        :species,
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolatus')
      )
    }
    let!(:another_tc){
      create(
        :species,
        :parent_id => parent.id,
        :taxon_name => create(:taxon_name, :scientific_name => 'lolcatus')
      )
    }
    let(:hybrid){
      build(
        :species,
        :name_status => 'H',
        :author_year => 'Taxonomus 2013',
        :hybrid_parent_scientific_name => tc.full_name,
        :other_hybrid_parent_scientific_name => another_tc.full_name,
        :full_name => 'Lolcatus lolcatus x lolatus'
      )
    }
    context "when new" do
      specify {
        lambda do
          hybrid.save
        end.should change(TaxonConcept, :count).by(1)
      }
      pending {
        hybrid.save
        tc.has_hybrids?.should be_true
      }
      specify {
        hybrid.save
        hybrid.is_hybrid?.should be_true
      }
    end
    context "when duplicate" do
      let(:duplicate){
        hybrid.dup
      }
      specify {
        lambda do
          hybrid.save
          duplicate.save
        end.should change(TaxonConcept, :count).by(1)
      }
    end
    context "when duplicate but author name different" do
      let(:duplicate){
        res = hybrid.dup
        res.author_year = 'Hemulen 2013'
        res
      }
      specify {
        lambda do
          hybrid.save
          duplicate.save
        end.should change(TaxonConcept, :count).by(2)
      }
      specify {
        hybrid.save
        hybrid.full_name.should == 'Lolcatus lolcatus x lolatus'
      }
    end
  end
end