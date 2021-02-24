require 'spec_helper'

describe TaxonConcept do
  context "Pseudomys fieldi" do
    include_context "Pseudomys fieldi"

    context "LISTING" do
      describe :cites_listing do
        context "for subspecies Pseudomys fieldi preaconis" do
          specify { @subspecies.cites_listing.should == 'I' }
        end
        context "for species Pseudomys fieldi" do
          specify { @species.cites_listing.should == 'I/NC' }
        end
      end

      describe :eu_listing do
        context "for subspecies Pseudomys fieldi preaconis" do
          specify { @subspecies.eu_listing.should == 'A' }
        end
        context "for species Pseudomys fieldi" do
          specify { @species.eu_listing.should == 'A/NC' }
        end
      end

      describe :cites_show do
        context "for subspecies Pseudomys fieldi preaconis" do
          specify { @subspecies.cites_show.should be_truthy }
        end
        context "for species Pseudomys fieldi" do
          specify { @species.cites_show.should be_truthy }
        end
      end

      # describe :eu_show do
      #   context "for subspecies Pseudomys fieldi preaconis" do
      #     specify{ @subspecies.eu_show.should be_truthy }
      #   end
      #   context "for species Pseudomys fieldi" do
      #     specify{ @species.eu_show.should be_truthy }
      #   end
      # end

    end

  end
end
