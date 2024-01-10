require 'spec_helper'

describe TaxonConcept do
  context "Platysternon megacephalum" do
    include_context "Platysternon megacephalum"

    context "LISTING" do
      describe :cites_listing do
        context 'for family Platysternidae' do
          specify { @family.cites_listing.should == 'I' }
        end
        context 'for species Platysternon megacephalum' do
          specify { @species.cites_listing.should == 'I' }
        end
      end

      describe :cites_listed do
        context "for species Platysternon megacephalum" do
          specify { @species.cites_listed.should == false }
        end
      end

      describe :cites_show do
        context "for species Platysternon megacephalum" do
          specify { @species.cites_show.should be_truthy }
        end
      end

      describe :eu_listing do
        context 'for family Platysternidae' do
          specify { @family.eu_listing.should == 'A' }
        end
        context 'for species Platysternon megacephalum' do
          specify { @species.eu_listing.should == 'A' }
        end
      end

      describe :eu_listed do
        context "for species Platysternon megacephalum" do
          specify { @species.eu_listed.should == false }
        end
      end

      describe :eu_show do
        context "for species Platysternon megacephalum" do
          specify { @species.eu_show.should be_truthy }
        end
      end

    end
  end
end
