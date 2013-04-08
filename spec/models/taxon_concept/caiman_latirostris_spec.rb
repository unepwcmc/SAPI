require 'spec_helper'

describe TaxonConcept do
  context "Caiman latirostris" do
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
          specify { @species.taxon_concept.standard_references.map(&:id).should include @ref.id }
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

      describe :eu_listed do
        context 'for order Crocodylia' do
          specify { @order.eu_listed.should be_true }
        end
        context "for family Alligatoridae" do
          specify { @family.eu_listed.should == false }
        end
        context "for genus Caiman" do
          specify { @genus.eu_listed.should == false }
        end
        context "for species Caiman latoristris" do
          specify { @species.eu_listed.should be_true }
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

      describe :ann_symbol do
        context "for species Caiman latirostris" do
          specify { @species.ann_symbol.should_not be_blank }
        end
      end

      describe :hash_ann_symbol do
        context "for species Caiman latirostris" do
          specify { @species.hash_ann_symbol.should be_blank }
        end
      end

    end
  end
end