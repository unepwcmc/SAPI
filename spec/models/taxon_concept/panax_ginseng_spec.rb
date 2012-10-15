require 'spec_helper'

describe TaxonConcept do
  include_context "Panax ginseng"

  context "LISTING" do

    describe :cites_listed do
      context "for species Panax ginseng" do
        specify { @species.cites_listed.should be_true }
      end
      context "for genus Panax" do
        specify { @genus.cites_listed.should == false }
      end
    end
  
    describe :current_listing do
      context "for species Panax ginseng" do
        specify { @species.current_listing.should == 'II/NC' }
      end
    end

    describe :specific_annotation_symbol do
      context "for species Panax ginseng" do
        specify { @species.specific_annotation_symbol.should_not be_blank }
      end
    end

    describe :generic_annotation_symbol do
      context "for species Panax ginseng" do
        specify { @species.generic_annotation_symbol.should == '#3' }
      end
    end

  end
end