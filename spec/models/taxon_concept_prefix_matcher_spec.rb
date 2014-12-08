require 'spec_helper'

describe TaxonConceptPrefixMatcher do
  let(:taxonomy){ create(:taxonomy) }
  let!(:rank1){ create(:rank, :taxonomic_position => '1') }
  let!(:rank2){ create(:rank, :taxonomic_position => '2') }
  let!(:rank3){ create(:rank, :taxonomic_position => '2.1') }
  let!(:rank4){ create(:rank, :taxonomic_position => '3') }

  let!(:taxon_concept1){
    create(:taxon_concept, :rank => rank1, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'Aaa')
    )
  }
  let!(:taxon_concept2){
    create(:taxon_concept, :rank => rank2, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'Aac'),
      :parent => taxon_concept1
    )
  }
  let!(:taxon_concept3){
    create(:taxon_concept, :rank => rank3, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'Aab')
    )
  }
  let!(:taxon_concept4){
    create(:taxon_concept, :rank => rank4, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'Abb'),
      :parent => taxon_concept2
    )
  }
  let!(:hybrid){
    tmp = create(:taxon_concept, :taxonomy => taxonomy,
      :taxon_name => create(:taxon_name, :scientific_name => 'Abc'),
      :name_status => 'H'
    )
    create(
      :taxon_relationship,
      :taxon_concept => taxon_concept4,
      :other_taxon_concept => tmp,
      :taxon_relationship_type => hybrid_relationship_type
    )
    tmp
  }
  context "when name status not specified" do
    let(:matcher_params){
      SearchParams.new(:taxonomy => {:id => taxonomy.id}, :scientific_name => 'Ab')
    }
    let(:matcher){ TaxonConceptPrefixMatcher.new matcher_params }
    specify{ matcher.taxon_concepts.should include(taxon_concept4)}
    specify{ matcher.taxon_concepts.should_not include(hybrid)}
  end

  context "when name status H" do
    let(:matcher_params){
      SearchParams.new(:taxonomy => {:id => taxonomy.id}, :scientific_name => 'Ab', :name_status => 'H')
    }
    let(:matcher){ TaxonConceptPrefixMatcher.new matcher_params }
    specify{ matcher.taxon_concepts.should_not include(taxon_concept4)}
    specify{ matcher.taxon_concepts.should include(hybrid)}
  end

  context "when rank scope applied" do
    let(:parent_matcher_params){
      SearchParams.new(
        :taxonomy => {:id => taxonomy.id},
        :rank => {:id => taxon_concept4.rank_id, :scope => :parent},
        :scientific_name => 'A'
      )
    }
    let(:parent_matcher){
      TaxonConceptPrefixMatcher.new parent_matcher_params
    }

    specify{ parent_matcher.taxon_concepts.map(&:full_name).should ==
      ['Aab', 'Aac'] }

    let(:ancestor_matcher_params){
      SearchParams.new(
        :taxonomy => {:id => taxonomy.id},
        :rank => {:id => taxon_concept4.rank_id, :scope => :ancestors},
        :scientific_name => 'AAA'
      )
    }
    let(:ancestor_matcher){
      TaxonConceptPrefixMatcher.new ancestor_matcher_params
    }
  
    specify{ ancestor_matcher.taxon_concepts.map(&:full_name).should ==
      ['Aaa'] }
  end
  context "when taxon concept scope applied" do
    let(:ancestor_matcher_params){
      SearchParams.new(
        :taxonomy => {:id => taxonomy.id},
        :taxon_concept => {:id => taxon_concept4.id, :scope => :ancestors},
        :scientific_name => 'A'
      )
    }
    let(:ancestor_matcher){
      TaxonConceptPrefixMatcher.new ancestor_matcher_params
    }

    specify{ ancestor_matcher.taxon_concepts.map(&:full_name).should ==
      ['Aaa', 'Aac'] }

    let(:descendant_matcher_params){
      SearchParams.new(
        :taxonomy => {:id => taxonomy.id},
        :taxon_concept => {:id => taxon_concept2.id, :scope => :descendants},
        :scientific_name => 'A'
      )
    }
    let(:descendant_matcher){
      TaxonConceptPrefixMatcher.new descendant_matcher_params
    }

    specify{ descendant_matcher.taxon_concepts.map(&:full_name).should ==
      ['Abb'] }
  end

end
