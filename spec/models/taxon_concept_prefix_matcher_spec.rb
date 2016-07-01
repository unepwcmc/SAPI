require 'spec_helper'

describe TaxonConceptPrefixMatcher do
  let(:taxonomy) { cites_eu }

  let!(:taxon_concept1) {
    create_cites_eu_order(
      taxon_name: create(:taxon_name, scientific_name: 'Aaa')
    )
  }
  let!(:taxon_concept2) {
    create_cites_eu_family(
      taxon_name: create(:taxon_name, scientific_name: 'Aac'),
      parent: taxon_concept1
    )
  }
  let!(:taxon_concept3) {
    create_cites_eu_subfamily(
      taxon_name: create(:taxon_name, scientific_name: 'Aab'),
      parent: taxon_concept2
    )
  }
  let!(:taxon_concept4) {
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Abb'),
      parent: taxon_concept3
    )
  }
  let!(:taxon_concept4_sibling) {
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Aaab'),
      parent: taxon_concept3
    )
  }
  let!(:hybrid) {
    tmp = create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Abc'),
      name_status: 'H'
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
    let(:matcher_params) {
      SearchParams.new(:taxonomy => { :id => taxonomy.id }, :scientific_name => 'Ab')
    }
    let(:matcher) { TaxonConceptPrefixMatcher.new matcher_params }
    specify { matcher.taxon_concepts.should include(taxon_concept4) }
    specify { matcher.taxon_concepts.should_not include(hybrid) }
  end

  context "when name status H" do
    let(:matcher_params) {
      SearchParams.new(:taxonomy => { :id => taxonomy.id }, :scientific_name => 'Ab', :name_status => 'H')
    }
    let(:matcher) { TaxonConceptPrefixMatcher.new matcher_params }
    specify { matcher.taxon_concepts.should_not include(taxon_concept4) }
    specify { matcher.taxon_concepts.should include(hybrid) }
  end

  context "when rank scope applied" do
    let(:parent_matcher_params) {
      SearchParams.new(
        :taxonomy => { :id => taxonomy.id },
        :rank => { :id => taxon_concept4.rank_id, :scope => :parent },
        :scientific_name => 'A'
      )
    }
    let(:parent_matcher) {
      TaxonConceptPrefixMatcher.new parent_matcher_params
    }

    specify {
      parent_matcher.taxon_concepts.map(&:full_name).should ==
      ['Aab', 'Aac']
    }

    let(:ancestor_matcher_params) {
      SearchParams.new(
        :taxonomy => { :id => taxonomy.id },
        :rank => { :id => taxon_concept4.rank_id, :scope => :ancestors },
        :scientific_name => 'AAA'
      )
    }
    let(:ancestor_matcher) {
      TaxonConceptPrefixMatcher.new ancestor_matcher_params
    }

    specify {
      ancestor_matcher.taxon_concepts.map(&:full_name).should ==
      ['Aaa']
    }

    let(:self_and_ancestor_matcher_params) {
      SearchParams.new(
        :taxonomy => { :id => taxonomy.id },
        :rank => { :id => taxon_concept4.rank_id, :scope => :self_and_ancestors },
        :scientific_name => 'AAA'
      )
    }
    let(:self_and_ancestor_matcher) {
      TaxonConceptPrefixMatcher.new self_and_ancestor_matcher_params
    }

    specify {
      self_and_ancestor_matcher.taxon_concepts.map(&:full_name).should ==
      ['Aaa', 'Aaab']
    }

  end
  context "when taxon concept scope applied" do
    let(:ancestor_matcher_params) {
      SearchParams.new(
        :taxonomy => { :id => taxonomy.id },
        :taxon_concept => { :id => taxon_concept4.id, :scope => :ancestors },
        :scientific_name => 'A'
      )
    }
    let(:ancestor_matcher) {
      TaxonConceptPrefixMatcher.new ancestor_matcher_params
    }

    specify {
      ancestor_matcher.taxon_concepts.map(&:full_name).should ==
      ['Aaa', 'Aab', 'Aac']
    }

    let(:descendant_matcher_params) {
      SearchParams.new(
        :taxonomy => { :id => taxonomy.id },
        :taxon_concept => { :id => taxon_concept2.id, :scope => :descendants },
        :scientific_name => 'A'
      )
    }
    let(:descendant_matcher) {
      TaxonConceptPrefixMatcher.new descendant_matcher_params
    }

    specify {
      descendant_matcher.taxon_concepts.map(&:full_name).should ==
      ['Aaab', 'Aab', 'Abb']
    }
  end

end
