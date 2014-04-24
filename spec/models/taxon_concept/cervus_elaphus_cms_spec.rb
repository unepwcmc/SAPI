require 'spec_helper'

describe TaxonConcept do
  context "Cervus elphus CMS" do
    include_context "Cervus elaphus CMS"

    context "LISTING" do
      describe :cms_listing do
        context "for species Cervus elaphus" do
          specify{ @species.cms_listing.should == 'I/II' }
        end
        context "for subspecies Cervus elaphus bactrianus" do
          specify { @subspecies1.cms_listing.should == 'I/II' }
        end
        context "for subspecies Cervus elaphus barbarus" do
          specify { @subspecies2.cms_listing.should == 'I/II' }
        end
      end

      describe :show_in_species_plus_ac do
        context "for subspecies Cervus elaphus bactrianus (instrument)" do
          specify{ @subspecies1.show_in_species_plus_ac.should be_true }
        end
        context "for subspecies Cervus elaphus barbarus (listing)" do
          specify{ @subspecies2.show_in_species_plus_ac.should be_true }
        end
      end

      describe :show_in_species_plus do
        context "for subspecies Cervus elaphus bactrianus (instrument)" do
          specify{ @subspecies1.show_in_species_plus.should be_true }
        end
        context "for subspecies Cervus elaphus barbarus (listing)" do
          specify{ @subspecies2.show_in_species_plus.should be_true }
        end
      end

    end
  end
end
