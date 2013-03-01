#Encoding: utf-8
require 'spec_helper'

describe TaxonConcept do
  context "Colophon" do
    include_context "Colophon"

    context "LISTING" do
      describe :current_listing do
        context "for genus Colophon" do
          specify { @genus.current_listing.should == 'III' }
        end
        context "for species Colophon barnardi" do
          specify { @species.current_listing.should == 'III' }
        end
      end

      describe :cites_listed do
        context "for genus Colophon" do
          specify { @genus.cites_listed.should == true}
        end
        context "for species Colophon barnardi" do
          specify { @species.cites_listed.should == false }
        end
      end

      describe :cites_show do
        context "for order Coleoptera" do
          specify { @order.cites_show.should be_false }
        end
        context "for family Lucanidae" do
          specify { @family.cites_show.should be_true }
        end
      end

      describe :current_party_ids do
        context "for genus Colophon" do
          specify { @genus.current_parties_ids.should == [GeoEntity.find_by_iso_code2('ZA').id] }
        end
        context "for species Colophon barnardi" do
          specify { @species.current_parties_ids.should == [GeoEntity.find_by_iso_code2('ZA').id] }
        end
      end

    end
  end
end