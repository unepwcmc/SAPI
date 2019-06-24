require 'spec_helper'

describe TaxonConcept do
  context "Canis lupus" do
    include_context "Canis lupus"
    context "LISTING" do
      describe :cites_listing do
        context "for species Canis lupus (population split listing)" do
          specify { @species.cites_listing.should == 'I/II' }
        end
      end

      describe :eu_listing do
        context "for species Canis lupus (population split listing)" do
          specify { @species.eu_listing.should == 'A/B' }
        end
      end

      describe :cites_listed do
        context "for species Canis lupus" do
          specify { @species.cites_listed.should be_truthy }
        end
        context "for subspecies Canis lupus crassodon" do
          specify { @subspecies.cites_listed.should be_blank }
        end
      end

      describe :eu_listed do
        context "for species Canis lupus" do
          specify { @species.eu_listed.should be_truthy }
        end
      end

      describe :show_in_species_plus_ac do
        context "for species Canis lupus" do
          specify { @species_ac.show_in_species_plus_ac.should be_truthy }
        end
        context "for subspecies Canis lupus crassodon" do
          specify { @subspecies_ac.show_in_species_plus_ac.should be_truthy }
        end
      end

      describe :show_in_checklist_ac do
        context "for species Canis lupus" do
          specify { @species_ac.show_in_checklist_ac.should be_truthy }
        end
        context "for subspecies Canis lupus crassodon" do
          specify { @subspecies_ac.show_in_checklist_ac.should be_falsey }
        end
      end

      describe :show_in_species_plus do
        context "for species Canis lupus" do
          specify { @species.show_in_species_plus.should be_truthy }
        end
        context "for subspecies Canis lupus crassodon" do
          specify { @subspecies.show_in_species_plus.should be_truthy }
        end
      end

    end
  end
end
