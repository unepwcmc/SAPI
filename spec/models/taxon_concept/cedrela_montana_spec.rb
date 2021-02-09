require 'spec_helper'

describe TaxonConcept do
  context "Cedrela montana" do
    include_context "Cedrela montana"

    context "LISTING" do
      describe :cites_listing do
        context 'for species Cedrela montana' do
          specify { @species.cites_listing.should be_blank }
        end
      end

      describe :cites_listed do
        context "for species Cedrela montana" do
          specify { @species.cites_listed.should be_nil }
        end
      end

      describe :cites_show do
        context "for species Cedrela montana" do
          specify { @species.cites_show.should be_falsey }
        end
      end

      describe :eu_listing do
        context 'for species Cedrela montana' do
          specify { @species.eu_listing.should == 'D' }
        end
      end

      describe :eu_listed do
        context "for species Cedrela montana" do
          specify { @species.eu_listed.should be_truthy }
        end
      end

      describe :eu_show do
        context "for species Cedrela montana" do
          specify { @species.eu_show.should be_truthy }
        end
      end

    end
  end
end
