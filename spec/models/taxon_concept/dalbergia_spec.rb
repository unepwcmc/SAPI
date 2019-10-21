require 'spec_helper'

describe TaxonConcept do
  context "Dalbergia" do
    include_context "Dalbergia"

    context "LISTING" do
      describe :cites_listing do
        context 'for species Dalbergia abbreviata' do
          specify { @species1.cites_listing.should == 'NC' }
        end
        context 'for species Dalbergia abrahamii' do
          specify { @species2.cites_listing.should == 'II' }
        end
      end

      describe :cites_listed do
        context "for species Dalbergia abbreviata" do
          specify { @species1.cites_listed.should be_nil }
        end
        context "for species Dalbergia abrahamii" do
          specify { @species2.cites_listed.should == false }
        end
      end

      describe :cites_show do
        context "for species Dalbergia abbreviata" do
          specify { @species1.cites_show.should be_falsey }
        end
        context "for species Dalbergia abrahamii" do
          specify { @species2.cites_show.should be_truthy }
        end
      end
    end
  end
end
