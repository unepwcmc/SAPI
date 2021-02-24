require 'spec_helper'

describe TaxonConcept do
  context "Moschus" do
    include_context "Moschus"

    context "LISTING" do
      describe :cites_listing do
        context "for genus Moschus" do
          specify { @genus.cites_listing.should == 'I/II' }
        end
        context "for species Moschus leucogaster" do
          specify { @species1.cites_listing.should == 'I' }
        end
        context "for species Moschus moschiferus" do
          specify { @species2.cites_listing.should == 'II' }
        end
        context "for subspecies Moschus moschiferus moschiferus" do
          specify { @subspecies.cites_listing.should == 'II' }
        end
      end

      describe :cites_listed do
        context "for genus Moschus" do
          specify { @genus.cites_listed.should be_truthy }
        end
        context "for species Moschus leucogaster" do
          specify { @species1.cites_listed.should == false }
        end
        context "for species Moschus moschiferus" do
          specify { @species2.cites_listed.should == false }
        end
        context "for subspecies Moschus moschiferus moschiferus" do
          specify { @subspecies.cites_listed.should == false }
        end
      end
    end

    context "CASCADING LISTING" do
      describe :current_cites_additions do
        context "for species Moschus leucogaster" do
          specify {
            @species1.current_cites_additions.size.should == 1
            addition = @species1.current_cites_additions.first
            addition.original_taxon_concept_id.should == @genus.id
            # should inherit just the I listing from split listed genus
            addition.species_listing_name.should == 'I'
          }
        end
        context "for species Moschus moschiferus" do
          specify {
            @species2.current_cites_additions.size.should == 1
            addition = @species2.current_cites_additions.first
            addition.original_taxon_concept_id.should == @genus.id
            # should inherit just the II listing from split listed genus
            addition.species_listing_name.should == 'II'
          }
        end
        context "for subspecies Moschus moschiferus moschiferus" do
          specify {
            @subspecies.current_cites_additions.size.should == 1
            addition = @subspecies.current_cites_additions.first
            addition.original_taxon_concept_id.should == @genus.id
            # should inherit just the II listing from split listed genus
            addition.species_listing_name.should == 'II'
          }
        end
      end
    end
  end
end
