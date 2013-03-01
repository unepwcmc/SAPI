require 'spec_helper'

describe TaxonConcept do
  context "Cervus elaphus" do
    include_context "Cervus elaphus"

    context "TAXONOMY" do
      describe :full_name do
        context "for subspecies Cervus elaphus bactrianus" do
          specify { @subspecies1.full_name.should == 'Cervus elaphus bactrianus' }
        end
        context "for species Cervus elaphus" do
          specify { @species.full_name.should == 'Cervus elaphus' }
        end
        context "for genus Cervus" do
          specify { @genus.full_name.should == 'Cervus' }
        end
      end
    end

    context "LISTING" do
      describe :current_listing do
        context "for species Cervus elaphus" do
          specify { @species.current_listing.should == 'I/II/III/NC' }
        end
        context "for subspecies Cervus elaphus bactrianus" do
          specify { @subspecies1.current_listing.should == 'II' }
        end
        context "for subspecies Cervus elaphus barbarus" do
          specify { @subspecies2.current_listing.should == 'III' }
        end
        context "for subspecies Cervus elaphus hanglu" do
          specify { @subspecies3.current_listing.should == 'I' }
        end
        context "for subspecies Cervus elaphus canadensis" do
          specify { @subspecies4.current_listing.should == 'NC' }
        end
      end

      describe :cites_listed do
        context "for order Artiodactyla" do
          specify { @order.cites_listed.should == false }
        end
        context "for family Cervidae" do
          specify { @family.cites_listed.should == false }
        end
        context "for genus Cervus" do
          specify { @genus.cites_listed.should == false }
        end
        context "for species Cervus elaphus" do
          specify { @species.cites_listed.should == false }
        end
        context "for subspecies Cervus elaphus bactrianus" do
          specify { @subspecies1.cites_listed.should be_true }
        end
        context "for subspecies Cervus elaphus barbarus" do
          specify { @subspecies2.cites_listed.should be_true }
        end
        context "for subspecies Cervus elaphus hanglu" do
          specify { @subspecies3.cites_listed.should be_true }
        end
        context "for subspecies Cervus elaphus canadensis" do
          specify { @subspecies4.cites_listed.should be_blank }
        end
      end

      describe :cites_show do
        context "for subspecies Cervus elaphus hanglu" do
          specify { @subspecies3.cites_show.should be_true }
        end
        context "for subspecies Cervus elaphus canadensis" do
          specify { @subspecies4.cites_show.should be_false }
        end
      end

    end
  end
end