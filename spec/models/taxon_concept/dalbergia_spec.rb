require 'spec_helper'

describe TaxonConcept do
  context "Dalbergia" do
    include_context "Dalbergia"

    context "LISTING" do
      describe :cites_listing do
        context 'for species Dalbergia abbreviata' do
          specify { expect(@species1.cites_listing).to eq('NC') }
        end
        context 'for species Dalbergia abrahamii' do
          specify { expect(@species2.cites_listing).to eq('II') }
        end
      end

      describe :cites_listed do
        context "for species Dalbergia abbreviata" do
          specify { expect(@species1.cites_listed).to be_nil }
        end
        context "for species Dalbergia abrahamii" do
          specify { expect(@species2.cites_listed).to eq(false) }
        end
      end

      describe :cites_show do
        context "for species Dalbergia abbreviata" do
          specify { expect(@species1.cites_show).to be_falsey }
        end
        context "for species Dalbergia abrahamii" do
          specify { expect(@species2.cites_show).to be_truthy }
        end
      end
    end
  end
end
