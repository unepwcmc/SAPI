require 'spec_helper'

describe TaxonConcept do
  context "Agave" do
    include_context "Agave"

    context "LISTING" do
      describe :cites_listing do
        context 'for species Agave parviflora' do
          specify { @species2.cites_listing.should == 'I' }
        end
        context 'for species Agave arizonica' do
          specify { @species1.cites_listing.should == 'NC' }
        end
      end

      describe :cites_listed do
        context "for species Agave parviflora" do
          specify { @species2.cites_listed.should be_truthy }
        end
        context "for species Agave arizonica" do
          specify { @species1.cites_listed.should be_nil }
        end
      end

      describe :cites_show do
        context "for species Agave parviflora" do
          specify { @species2.cites_show.should be_truthy }
        end
        context "for species Agave arizonica" do
          specify { @species1.cites_show.should be_falsey }
        end
      end

      describe :eu_listing do
        context 'for species Agave parviflora' do
          specify { @species2.eu_listing.should == 'A' }
        end
        context 'for species Agave arizonica' do
          specify { @species1.eu_listing.should == 'NC' }
        end
      end

      describe :eu_listed do
        context "for species Agave parviflora" do
          specify { @species2.eu_listed.should be_truthy }
        end
        context "for species Agave arizonica" do
          specify { @species1.eu_listed.should be_nil }
        end
      end

      describe :eu_show do
        context "for species Agave parviflora" do
          specify { @species2.eu_show.should be_truthy }
        end
        context "for species Agave arizonica" do
          specify { @species1.eu_show.should be_falsey }
        end
      end

    end
  end
end
