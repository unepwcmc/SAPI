require 'spec_helper'

describe TaxonConcept do
  include_context "Caiman latirostris"

  context "REFERENCES" do
    describe :cites_accepted do
      context 'for species Caiman latirostris' do
        specify { @species.cites_accepted.should be_true }
      end
      context "for species Alligator cynocephalus" do
        specify { @species1.cites_accepted.should == false }
      end
    end
    describe :standard_references do
      context 'for species Caiman latirostris' do
        specify { @species.standard_references.should include @ref.id }
      end
    end
  end
  context "LISTING" do
    describe :current_listing do
      context 'for species Caiman latirostris' do
        specify { @species.current_listing.should == 'I/II' }
      end
    end

    describe :cites_listed do
      context 'for order Crocodylia' do
        specify { @order.cites_listed.should be_true }
      end
      context "for family Alligatoridae" do
        specify { @family.cites_listed.should == false }
      end
      context "for genus Caiman" do
        specify { @genus.cites_listed.should == false }
      end
      context "for species Caiman latoristris" do
        specify { @species.cites_listed.should be_true }
      end
    end

    describe :cites_show do
      context "for order Crocodylia" do
        specify { @order.cites_show.should be_true }
      end
      context "for family Alligatoridae" do
        specify { @family.cites_show.should be_true }
      end
      context "for genus Caiman" do
        specify { @genus.cites_show.should be_true }
      end
      context "for species Caiman latoristris" do
        specify { @species.cites_show.should be_true }
      end
    end

    describe :specific_annotation_symbol do
      context "for species Caiman latirostric" do
        specify { @species.specific_annotation_symbol.should_not be_blank }
      end
    end

    describe :generic_annotation_symbol do
      context "for species Caiman latirostric" do
        specify { @species.generic_annotation_symbol.should be_blank }
      end
    end

  end
end