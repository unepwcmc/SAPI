require 'spec_helper'

describe Checklist::HigherTaxaItem do

  describe :ancestors_path do
    context "when animal" do
      let(:taxon_concept) {
        obj = double('MTaxonConcept',
          :rank_name => 'FAMILY',
          :kingdom_name => 'Animalia',
          :phylum_name => 'Chordata',
          :class_name => 'Reptilia',
          :order_name => 'Crocodylia',
          :family_name => 'Alligatoridae'
        )
      }
      subject { Checklist::HigherTaxaItem.new(taxon_concept) }
      specify { subject.ancestors_path.should == 'Chordata,Reptilia,Crocodylia,Alligatoridae' }
    end
    context "when plant" do
      let(:taxon_concept) {
        obj = double('MTaxonConcept',
          :rank_name => 'FAMILY',
          :kingdom_name => 'Plantae',
          :phylum_name => nil,
          :class_name => nil,
          :order_name => 'Liliales',
          :family_name => 'Agavaceae'
        )
      }
      subject { Checklist::HigherTaxaItem.new(taxon_concept) }
      specify { subject.ancestors_path.should == 'Agavaceae' }
    end
  end

end
