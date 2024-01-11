require 'spec_helper'

describe TaxonConcept do
  context "Cervus elphus CMS" do
    include_context "Cervus elaphus CMS"

    context "LISTING" do
      describe :cms_listing do
        context "for species Cervus elaphus" do
          specify { expect(@species.cms_listing).to eq('I/II') }
        end
        context "for subspecies Cervus elaphus bactrianus" do
          specify { expect(@subspecies1.cms_listing).to eq('I/II') }
        end
        context "for subspecies Cervus elaphus barbarus" do
          specify { expect(@subspecies2.cms_listing).to eq('I/II') }
        end
      end

      describe :show_in_species_plus_ac do
        context "for subspecies Cervus elaphus bactrianus (instrument)" do
          specify { expect(@subspecies1_ac.show_in_species_plus_ac).to be_truthy }
        end
        context "for subspecies Cervus elaphus barbarus (listing)" do
          specify { expect(@subspecies2_ac.show_in_species_plus_ac).to be_truthy }
        end
      end

      describe :show_in_species_plus do
        context "for subspecies Cervus elaphus bactrianus (instrument)" do
          specify { expect(@subspecies1.show_in_species_plus).to be_truthy }
        end
        context "for subspecies Cervus elaphus barbarus (listing)" do
          specify { expect(@subspecies2.show_in_species_plus).to be_truthy }
        end
      end

    end
  end
end
