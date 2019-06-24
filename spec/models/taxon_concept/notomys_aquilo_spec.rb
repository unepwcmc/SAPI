require 'spec_helper'

describe TaxonConcept do
  context "Notomys aquilo" do
    include_context "Notomys aquilo"

    context "LISTING" do
      describe :cites_listing do
        context "for genus Notomys" do
          specify { @genus.cites_listing.should == 'NC' }
        end
        context "for species Notomys aquilo" do
          specify { @species.cites_listing.should == 'NC' }
        end
      end

      describe :cites_show do
        context "for genus Notomys" do
          specify { @genus.cites_show.should be_falsey }
        end
        context "for species Notomys aquilo" do
          specify { @species.cites_show.should be_falsey }
        end
      end

    end

  end
end
