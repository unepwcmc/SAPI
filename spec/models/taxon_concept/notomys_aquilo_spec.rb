require 'spec_helper'

describe TaxonConcept do
  context "Notomys aquilo" do
    include_context "Notomys aquilo"

    context "LISTING" do
      describe :cites_listing do
        context "for genus Notomys" do
          specify{ @genus.cites_listing.should == 'NC' }
        end
        context "for species Notomys aquilo" do
          specify{ @species.cites_listing.should == 'NC' }
        end
      end

      describe :eu_listing do
        context "for genus Notomys" do
          specify{ @genus.eu_listing.should == 'NC' }
        end
        context "for species Notomys aquilo" do
          specify{ @species.eu_listing.should == 'NC' }
        end
      end

      describe :cites_show do
        context "for genus Notomys" do
          specify{ @genus.cites_show.should be_false }
        end
        context "for species Notomys aquilo" do
          specify{ @species.cites_show.should be_false }
        end
      end

      describe :eu_show do
        context "for genus Notomys" do
          specify{ @genus.eu_show.should be_false }
        end
        context "for species Notomys aquilo" do
          specify{ @species.eu_show.should be_false }
        end
      end

    end

  end
end
