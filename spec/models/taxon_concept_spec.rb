require 'spec_helper'

describe TaxonConcept do
  context "when importing taxonomy data" do
    before(:all) do
      @kingdom = create(
        :kingdom,
        :taxon_name => create(:taxon_name, :scientific_name => 'Fauna')
      )
      @phylum = create(
        :phylum,
        :taxon_name => create(:taxon_name, :scientific_name => 'Chordata'),
        :parent => @kingdom
      )      
      @klass = create(
        :class,
        :taxon_name => create(:taxon_name, :scientific_name => 'Reptilia'),
        :parent => @phylum
      )
      @order = create(
        :order,
        :taxon_name => create(:taxon_name, :scientific_name => 'Serpentes'),
        :parent => @klass
      )
      @family = create(
        :family,
        :taxon_name => create(:taxon_name, :scientific_name => 'Boidae'),
        :parent => @order
      )
      @genus = create(
        :genus,
        :taxon_name => create(:taxon_name, :scientific_name => 'Boa'),
        :parent => @family        
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
    context "Boa constrictor" do
      describe :full_name do
        it "should be trinomen for subspecies: Boa constrictor occidentalis" do
          @subspecies.reload.full_name.should == 'Boa constrictor occidentalis'
        end
        it "should be binomen for species: Boa constrictor" do
          @species.reload.full_name.should == 'Boa constrictor'
        end
        it "should be single name for genus: Boa" do
          @genus.reload.full_name.should == 'Boa'
        end
      end
      describe :rank do
        it "should be SPECIES" do
          @species.reload.rank_name.should == 'SPECIES'
        end
      end
      describe :parents do
        it "should have Boidae as family" do
          @species.reload.family_name == 'Boidae'
        end
        it "should have Serpentes as order" do
          @species.reload.order_name == 'Serpentes'
        end
        it "should have Reptilia as class" do
          @species.reload.class_name == 'Reptilia'
        end
      end
    end
  end
end