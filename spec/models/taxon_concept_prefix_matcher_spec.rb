require 'spec_helper'

describe TaxonConceptPrefixMatcher do
  let(:taxonomy){ create(:taxonomy) }
  let!(:rank1){ create(:rank, :taxonomic_position => '1') }
  let!(:rank2){ create(:rank, :taxonomic_position => '2') }
  let!(:rank3){ create(:rank, :taxonomic_position => '2.1') }
  let!(:rank4){ create(:rank, :taxonomic_position => '3') }

  let!(:taxon_concept1){
    create(:taxon_concept, :rank => rank1, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'AAA')
    )
  }
  let!(:taxon_concept2){
    create(:taxon_concept, :rank => rank2, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'AAA'),
      :parent => taxon_concept1
    )
  }
  let!(:taxon_concept3){
    create(:taxon_concept, :rank => rank3, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'AAB')
    )
  }
  let!(:taxon_concept4){
    create(:taxon_concept, :rank => rank4, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'ABB'),
      :parent => taxon_concept2
    )
  }

  context "when rank scope applied" do
    let(:parent_matcher){
      TaxonConceptPrefixMatcher.new(
        :taxonomy => {:id => taxonomy.id},
        :rank => {:id => taxon_concept4.rank_id, :scope => :parent},
        :scientific_name => 'A'
      )
    }
  
    specify{ parent_matcher.taxon_concepts.map(&:full_name).should ==
      ['AAA', 'AAB'] }
  
    let(:ancestor_matcher){
      TaxonConceptPrefixMatcher.new(
        :taxonomy => {:id => taxonomy.id},
        :rank => {:id => taxon_concept4.rank_id, :scope => :ancestors},
        :scientific_name => 'AAA'
      )
    }
  
    specify{ ancestor_matcher.taxon_concepts.map(&:full_name).should ==
      ['AAA', 'AAA'] }
  end
  context "when taxon concept scope applied" do
    let(:ancestor_matcher){
      TaxonConceptPrefixMatcher.new(
        :taxonomy => {:id => taxonomy.id},
        :taxon_concept => {:id => taxon_concept4.id, :scope => :ancestors},
        :scientific_name => 'A'
      )
    }

    specify{ ancestor_matcher.taxon_concepts.map(&:full_name).should ==
      ['AAA', 'AAA'] }

    let(:descendant_matcher){
      TaxonConceptPrefixMatcher.new(
        :taxonomy => {:id => taxonomy.id},
        :taxon_concept => {:id => taxon_concept2.id, :scope => :descendants},
        :scientific_name => 'A'
      )
    }

    specify{ descendant_matcher.taxon_concepts.map(&:full_name).should ==
      ['ABB'] }
  end

end
