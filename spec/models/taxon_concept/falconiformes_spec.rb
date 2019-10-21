require 'spec_helper'

describe TaxonConcept do
  context "Falconiformes" do
    include_context "Falconiformes"

    context "TAXONOMY" do
      describe :rank_name do
        context "for Falco hybrid" do
          specify { @hybrid.rank_name.should == Rank::GENUS }
        end
      end
    end

    context "LISTING" do
      describe :cites_listing do
        context "for order Falconiformes" do
          specify { @order.cites_listing.should == 'I/II/III/NC' }
        end
        context "for species Falco araea" do
          specify { @species2_1.cites_listing.should == 'I' }
        end
        context "for species Falco alopex (H)" do
          specify { @species2_2.cites_listing.should == 'II' }
        end
        context "for species Gymnogyps californianus" do
          specify { @species1_1.cites_listing.should == 'I' }
        end
        context "for species Sarcoramphus papa" do
          specify { @species1_2.cites_listing.should == 'III' }
        end
        context "for species Vultur atratus" do
          specify { @species1_3.cites_listing.should == 'NC' }
        end
      end

      describe :eu_listing do
        context "for order Falconiformes" do
          specify { @order.eu_listing.should == 'A/B/C/NC' }
        end
        context "for species Falco araea" do
          specify { @species2_1.eu_listing.should == 'A' }
        end
        context "for species Falco alopex (H)" do
          specify { @species2_2.eu_listing.should == 'B' }
        end
        context "for species Gymnogyps californianus" do
          specify { @species1_1.eu_listing.should == 'A' }
        end
        context "for species Sarcoramphus papa" do
          specify { @species1_2.eu_listing.should == 'C' }
        end
        context "for species Vultur atratus" do
          specify { @species1_3.eu_listing.should == 'NC' }
        end
      end

      describe :cites_status do
        context "for genus Vultur" do
          specify { @genus1_3.cites_status.should == 'EXCLUDED' }
        end
        context "for species Vultur atratus" do
          specify { @species1_3.cites_status.should == 'EXCLUDED' }
        end
      end

      describe :cites_listed do
        context "for order Falconiformes" do
          specify { @order.cites_listed.should be_truthy }
        end
        context "for family Falconidae (inclusion in higher taxa listing)" do
          specify { @family2.cites_listed.should == false }
        end
        context "for genus Falco" do
          specify { @genus2_1.cites_listed.should == false }
        end
        context "for species Falco araea" do
          specify { @species2_1.cites_listed.should be_truthy }
        end
        context "for species Falco alopex" do
          specify { @species2_2.cites_listed.should == false }
        end
        context "for species Vultur atratus" do
          specify { @species1_3.cites_listed.should be_blank }
        end
        context "for subspecies Falco peregrinus peregrinus" do
          specify { @subspecies2_3_1.cites_listed.should == false }
        end
      end

      describe :eu_listed do
        context "for order Falconiformes" do
          specify { @order.eu_listed.should be_truthy }
        end
        context "for family Falconidae (inclusion in higher taxa listing)" do
          specify { @family2.eu_listed.should == false }
        end
        context "for genus Falco" do
          specify { @genus2_1.eu_listed.should == false }
        end
        context "for species Falco araea" do
          specify { @species2_1.eu_listed.should be_truthy }
        end
        context "for species Falco alopex" do
          specify { @species2_2.eu_listed.should == false }
        end
        context "for species Vultur atratus" do
          specify { @species1_3.eu_listed.should be_blank }
        end
        context "for subspecies Falco peregrinus peregrinus" do
          specify { @subspecies2_3_1.eu_listed.should == false }
        end
      end

      describe :cites_show do
        context "for order Falconiformes" do
          specify { @order.cites_show.should be_truthy }
        end
        context "for family Falconidae" do
          specify { @family2.cites_show.should be_truthy }
        end
        context "for Falco hybrid" do
          specify { @hybrid.cites_show.should be_falsey }
        end
      end

      describe :show_in_checklist_ac do
        context "for subspecies Falco peregrinus peregrinus" do
          specify { @subspecies2_3_1_ac.show_in_checklist_ac.should be_falsey }
        end
      end

      describe :show_in_species_plus_ac do
        context "for subspecies Falco peregrinus peregrinus" do
          specify { @subspecies2_3_1_ac.show_in_species_plus_ac.should be_truthy }
        end
      end

    end
  end
end
