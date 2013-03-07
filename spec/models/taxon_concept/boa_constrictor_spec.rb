require 'spec_helper'

describe TaxonConcept do
  context "Boa constrictor" do
    include_context :designations
    include_context :ranks
    include_context "Boa constrictor"
    context "TAXONOMY" do
      describe :full_name do
        it "should be trinomen for subspecies: Boa constrictor occidentalis" do
          @subspecies1.full_name.should == 'Boa constrictor occidentalis'
        end
        it "should be binomen for species: Boa constrictor" do
          @species.full_name.should == 'Boa constrictor'
        end
        it "should be single name for genus: Boa" do
          @genus.full_name.should == 'Boa'
        end
      end

      describe :parents do
        it "should have Boidae as family" do
          @species.family_name == 'Boidae'
        end
        it "should have Serpentes as order" do
          @species.order_name == 'Serpentes'
        end
        it "should have Reptilia as class" do
          @species.class_name == 'Reptilia'
        end
      end
    end

    context "LISTING" do
      describe :current_listing do
        it "should be I at subspecies level Boa constrictor occidentalis" do
          @subspecies1.current_listing.should == 'I'
        end
        it "should be II at subspecies level Boa constrictor constrictor" do
          @subspecies2.current_listing.should == 'II'
        end
        it "should be I/II at species level Boa constrictor" do
          @species.current_listing.should == 'I/II'
        end
      end

      describe :cites_listed do
        it "should be true for family Boidae" do
          @family.cites_listed.should be_true
        end
        it "should be false for genus Boa" do
          @genus.cites_listed.should == false
        end
        it "should be false for species Boa constrictor (inclusion in higher taxa listing)" do
          @species.cites_listed.should == false
        end
        it "should be true for subspecies Boa constrictor occidentalis" do
          @subspecies1.cites_listed.should be_true
        end
      end

    end

  end
end
