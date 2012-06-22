require 'spec_helper'

describe TaxonConcept do
  before(:each) do

  end
  describe :full_name do
    before do
      @genus = create(
        :genus,
        :taxon_name => create(:taxon_name, :scientific_name => 'Boa')
      )
      @species = create(
        :species,
        :taxon_name => create(:taxon_name, :scientific_name => 'Constrictor'),
        :parent => @genus
      )
      @subspecies = create(
        :subspecies,
        :taxon_name => create(:taxon_name, :scientific_name => 'occidentalis'),
        :parent => @species
      )
      Sapi::rebuild
    end
    it "should be trinomen for subspecies" do
      @subspecies.reload.full_name.should == 'Boa constrictor occidentalis'
    end
    it "should be binomen for species" do
      @species.reload.full_name.should == 'Boa constrictor'
    end
    it "should be scientific_name on its own in other cases" do
      @genus.reload.full_name.should == 'Boa'
    end
  end
end