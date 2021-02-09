require 'spec_helper'

describe TaxonConcept do
  context "Loxodonta africana" do
    include_context "Loxodonta africana"
    context "TAXONOMY" do
      describe :full_name do
        context "for species Loxodonta africana" do
          specify { @species.full_name.should == 'Loxodonta africana' }
        end
        context "for genus Loxodonta" do
          specify { @genus.full_name.should == 'Loxodonta' }
        end
      end
      describe :rank do
        context "for species Loxodonta africana" do
          specify { @species.rank_name.should == 'SPECIES' }
        end
      end
      describe :ancestors do
        context "family" do
          specify { @species.family_name == 'Elephantidae' }
        end
        context "order" do
          specify { @species.order_name == 'Proboscidea' }
        end
        context "class" do
          specify { @species.class_name == 'Mammalia' }
        end
      end
    end

    context "LISTING" do
      describe :cites_listing do
        context "for species Loxodonta africana (population split listing)" do
          specify { @species.cites_listing.should == 'I/II' }
        end
      end

      describe :eu_listing do
        context "for species Loxodonta africana (population split listing)" do
          specify { @species.eu_listing.should == 'A/B' }
        end
      end

      describe :cites_listed do
        context "for species Loxodonta africana" do
          specify { @species.cites_listed.should be_truthy }
        end
        context "for family Elephantidae" do
          specify { @family.cites_listed.should == false }
        end
      end

      describe :eu_listed do
        context "for species Loxodonta africana" do
          specify { @species.eu_listed.should be_truthy }
        end
        context "for family Elephantidae" do
          specify { @family.eu_listed.should == false }
        end
      end

    end
  end
end
