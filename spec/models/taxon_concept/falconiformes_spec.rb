require 'spec_helper'

describe TaxonConcept do
  context "Falconiformes" do
    include_context "Falconiformes"

    context "LISTING" do
      describe :current_listing do
        context "for order Falconiformes" do
          specify { @order.current_listing.should == 'I/II/III/NC' }
        end
        context "for species Falco araea" do
          specify { @species2_1.current_listing.should == 'I' }
        end
        context "for species Falco alopex (H)" do
          specify { @species2_2.current_listing.should == 'II' }
        end
        context "for species Gymnogyps californianus" do
          specify { @species1_1.current_listing.should == 'I' }
        end
        context "for species Sarcoramphus papa" do
          specify { @species1_2.current_listing.should == 'III' }
        end
        context "for species Vultur atratus" do
          specify { @species1_3.current_listing.should == 'NC' }
        end
      end

      describe :cites_fully_covered do
        context "for order Falconiformes" do
          specify { @order.cites_fully_covered.should be_false }
        end
        context "for family Cathartidae" do
          specify { @family1.cites_fully_covered.should be_false }
        end
        context "for family Falconidae" do
          specify { @family2.cites_fully_covered.should be_true }
        end
        context "for genus Vultur" do
          specify { @genus1_3.cites_fully_covered.should be_false }
        end
        context "for species Falco alopex (H)" do
          specify { @species2_2.cites_fully_covered.should be_true }
        end
      end

      describe :cites_deleted do
                context "for species Falco alopex (H)" do
          specify { @species2_2.cites_deleted.should be_false }
        end
      end

      describe :cites_excluded do
        context "for genus Vultur" do
          specify { @genus1_3.cites_excluded.should be_true }
        end
        context "for species Vultur atratus" do
          specify { @species1_3.cites_excluded.should be_true }
        end
        context "for species Falco alopex (H)" do
          specify { @species2_2.cites_excluded.should be_false }
        end
      end

      describe :cites_listed do
        context "for order Falconiformes" do
          specify { @order.cites_listed.should be_true }
        end
        context "for family Falconidae (inclusion in higher taxa listing)" do
          specify { @family2.cites_listed.should == false }
        end
        context "for genus Falco" do
          specify { @genus2_1.cites_listed.should == false }
        end
        context "for species Falco araea" do
          specify { @species2_1.cites_listed.should be_true }
        end
        context "for species Falco alopex" do
          specify { @species2_2.cites_listed.should == false }
        end
        context "for species Vultur atratus" do
          specify { @species1_3.cites_listed.should be_blank }
        end
      end

    end
  end
end