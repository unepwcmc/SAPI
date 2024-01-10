require 'spec_helper'

describe TaxonConcept do
  context "Diospyros" do
    include_context "Diospyros"

    context "LISTING" do
      describe :cites_listing do
        context 'for species Diospyros aculeata' do
          specify { @species1.cites_listing.should == 'II' }
        end
        context 'for species Diospyros acuta' do
          specify { @species2.cites_listing.should == 'NC' }
        end
      end

      describe :cites_listed do
        context "for species Diospyros aculeata" do
          specify { @species1.cites_listed.should == false }
        end
        context "for species Diospyros acuta" do
          specify { @species2.cites_listed.should be_nil }
        end
      end

      describe :cites_show do
        context "for species Diospyros aculeata" do
          specify { @species1.cites_show.should be_truthy }
        end
        context "for species Diospyros acuta" do
          specify { @species2.cites_show.should be_falsey }
        end
      end

      describe :eu_listing do
        context 'for species Diospyros aculeata' do
          specify { @species1.eu_listing.should == 'B' }
        end
        context 'for species Diospyros acuta' do
          specify { @species2.eu_listing.should == 'NC' }
        end
      end

      describe :eu_listed do
        context "for species Diospyros aculeata" do
          specify { @species1.eu_listed.should == false }
        end
        context "for species Diospyros acuta" do
          specify { @species2.eu_listed.should be_nil }
        end
      end

      describe :eu_show do
        context "for species Diospyros aculeata" do
          specify { @species1.eu_show.should be_truthy }
        end
        context "for species Diospyros acuta" do
          specify { @species2.eu_show.should be_falsey }
        end
      end

    end
  end
end
