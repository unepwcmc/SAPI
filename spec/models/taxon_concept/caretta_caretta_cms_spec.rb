require 'spec_helper'

describe TaxonConcept do
  context "Caretta caretta CMS" do
    include_context "Caretta caretta CMS"

    context "LISTING" do
      describe :cms_listing do
        context "for family Cheloniidae" do
          specify { expect(@family.cms_listing).to eq('I/II') }
        end
        context "for species Caretta caretta" do
          specify { expect(@species.cms_listing).to eq('I/II') }
        end
      end

      describe :cms_listed do
        context "for family Cheloniidae" do
          specify { expect(@family.cms_listed).to be_truthy }
        end
        context "for species Caretta caretta" do
          specify { expect(@species.cms_listed).to be_truthy }
        end
      end
    end

    context "CASCADING LISTING" do
      describe :current_cms_additions do
        context "for family Cheloniidae" do
          specify {
            expect(@family.current_cms_additions.size).to eq(1)
          }
        end
        context "for species Caretta caretta" do
          specify {
            expect(@species.current_cms_additions.size).to eq(2)
          }
        end
      end
    end

  end
end
