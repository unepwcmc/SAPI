require 'spec_helper'

describe TaxonConcept do
  context "Boa constrictor" do
    include_context "Boa constrictor"
    context "TAXONOMY" do
      describe :full_name do
        context "for subspecies Boa constrictor occidentalis" do
          specify{ @subspecies1.full_name.should == 'Boa constrictor occidentalis' }
        end
        context "for species Boa constrictor" do
          specify{ @species.full_name.should == 'Boa constrictor' }
        end
        context "for genus Boa" do
          specify{ @genus.full_name.should == 'Boa' }
        end
      end

      describe :ancestors do
        context "family" do
          specify{ @species.family_name.should == 'Boidae' }
        end
        context "order" do
          specify{ @species.order_name.should == 'Serpentes' }
        end
        context "class" do
          specify{ @species.class_name.should == 'Reptilia' }
        end
      end
    end

    context "LISTING" do
      describe :cites_listing do
        context "for subspecies Boa constrictor occidentalis" do
          specify{ @subspecies1.cites_listing.should == 'I' }
        end
        context "for subspecies Boa constrictor constrictor" do
          specify{ @subspecies2.cites_listing.should == 'II' }
        end
        context "for species Boa constrictor" do
          specify{ @species.cites_listing.should == 'I/II' }
        end
      end

      describe :eu_listing do
        context "for subspecies Boa constrictor occidentalis" do
          specify{ @subspecies1.eu_listing.should == 'A' }
        end
        context "for subspecies Boa constrictor constrictor" do
          specify{ @subspecies2.eu_listing.should == 'B' }
        end
        context "for species Boa constrictor" do
          specify{ @species.eu_listing.should == 'A/B' }
        end
      end

      describe :cites_listed do
        context "for family Boidae" do
          specify{ @family.cites_listed.should be_true }
        end
        context "for genus Boa" do
          specify{ @genus.cites_listed.should == false }
        end
        context "for species Boa constrictor (inclusion in higher taxa listing)" do
          specify{ @species.cites_listed.should == false }
        end
        context "for subspecies Boa constrictor occidentalis" do
          specify{ @subspecies1.cites_listed.should be_true }
        end
      end

      describe :eu_listed do
        context "for family Boidae" do
          specify{ @family.eu_listed.should be_true }
        end
        context "for genus Boa" do
          specify{ @genus.eu_listed.should == false }
        end
        context "for species Boa constrictor (inclusion in higher taxa listing)" do
          specify{ @species.eu_listed.should == false }
        end
        context "for subspecies Boa constrictor occidentalis" do
          specify{ @subspecies1.eu_listed.should be_true }
        end
      end

    end

  end
end
