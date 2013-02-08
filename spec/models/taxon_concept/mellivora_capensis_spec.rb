require 'spec_helper'

describe TaxonConcept do
  context "Mellivora capensis" do
    include_context "Mellivora capensis"
    context "LISTING" do
      describe :current_listing do
        context "for species Mellivora capensis" do
          specify { @species.current_listing.should == 'III' }
        end
      end

      describe :cites_listed do
        context "for family Mustelinae" do
          specify { @family.cites_listed.should == false }
        end
        context "for genus Mellivora" do
          specify { @genus.cites_listed.should == false }
        end
        context "for species Mellivora capensis" do
          specify { @species.cites_listed.should be_true }
        end
      end

      describe :current_party_ids do
        context "for species Mellivora capensis" do
          specify { @species.current_party_ids.should == [GeoEntity.find_by_iso_code2('BW').id] }
        end
      end

    end
  end
end