require 'spec_helper'

describe TaxonConcept do
  context "Caretta caretta CMS" do
    include_context "Caretta caretta CMS"

    context "LISTING" do
      describe :cms_listing do
        context "for family Cheloniidae" do
          specify { @family.cms_listing.should == 'I/II' }
        end
        context "for species Caretta caretta" do
          specify { @species.cms_listing.should == 'I/II' }
        end
      end

      describe :cms_listed do
        context "for family Cheloniidae" do
          specify { @family.cms_listed.should be_truthy }
        end
        context "for species Caretta caretta" do
          specify { @species.cms_listed.should be_truthy }
        end
      end
    end

    context "CASCADING LISTING" do
      describe :current_cms_additions do
        context "for family Cheloniidae" do
          specify {
            @family.current_cms_additions.size.should == 1
          }
        end
        context "for species Caretta caretta" do
          specify {
            @species.current_cms_additions.size.should == 2
          }
        end
      end
    end

  end
end
