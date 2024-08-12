require 'spec_helper'

describe TaxonConceptPrefixMatcher do
  let(:taxonomy) { cites_eu }

  let!(:taxon_concept1) do
    create_cites_eu_order(
      taxon_name: create(:taxon_name, scientific_name: 'Aaa')
    )
  end
  let!(:taxon_concept2) do
    create_cites_eu_family(
      taxon_name: create(:taxon_name, scientific_name: 'Aac'),
      parent: taxon_concept1
    )
  end
  let!(:taxon_concept3) do
    create_cites_eu_subfamily(
      taxon_name: create(:taxon_name, scientific_name: 'Aab'),
      parent: taxon_concept2
    )
  end
  let!(:taxon_concept4) do
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Abb'),
      parent: taxon_concept3
    )
  end
  let!(:taxon_concept4_sibling) do
    create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Aaab'),
      parent: taxon_concept3
    )
  end
  let!(:hybrid) do
    tmp = create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Abc'),
      name_status: 'H'
    )
    create(
      :taxon_relationship,
      taxon_concept: taxon_concept4,
      other_taxon_concept: tmp,
      taxon_relationship_type: hybrid_relationship_type
    )
    tmp
  end
  context 'when name status not specified' do
    let(:matcher_params) do
      SearchParams.new(taxonomy: { id: taxonomy.id }, scientific_name: 'Ab')
    end
    let(:matcher) { TaxonConceptPrefixMatcher.new matcher_params }
    specify { expect(matcher.taxon_concepts).to include(taxon_concept4) }
    specify { expect(matcher.taxon_concepts).not_to include(hybrid) }
  end

  context 'when name status H' do
    let(:matcher_params) do
      SearchParams.new(taxonomy: { id: taxonomy.id }, scientific_name: 'Ab', name_status: 'H')
    end
    let(:matcher) { TaxonConceptPrefixMatcher.new matcher_params }
    specify { expect(matcher.taxon_concepts).not_to include(taxon_concept4) }
    specify { expect(matcher.taxon_concepts).to include(hybrid) }
  end

  context 'when rank scope applied' do
    let(:parent_matcher_params) do
      SearchParams.new(
        taxonomy: { id: taxonomy.id },
        rank: { id: taxon_concept4.rank_id, scope: :parent },
        scientific_name: 'A'
      )
    end
    let(:parent_matcher) do
      TaxonConceptPrefixMatcher.new parent_matcher_params
    end

    specify do
      expect(parent_matcher.taxon_concepts.map(&:full_name)).to eq(
      [ 'Aab', 'Aac' ]
      )
    end

    let(:ancestor_matcher_params) do
      SearchParams.new(
        taxonomy: { id: taxonomy.id },
        rank: { id: taxon_concept4.rank_id, scope: :ancestors },
        scientific_name: 'AAA'
      )
    end
    let(:ancestor_matcher) do
      TaxonConceptPrefixMatcher.new ancestor_matcher_params
    end

    specify do
      expect(ancestor_matcher.taxon_concepts.map(&:full_name)).to eq(
      [ 'Aaa' ]
      )
    end

    let(:self_and_ancestor_matcher_params) do
      SearchParams.new(
        taxonomy: { id: taxonomy.id },
        rank: { id: taxon_concept4.rank_id, scope: :self_and_ancestors },
        scientific_name: 'AAA'
      )
    end
    let(:self_and_ancestor_matcher) do
      TaxonConceptPrefixMatcher.new self_and_ancestor_matcher_params
    end

    specify do
      expect(self_and_ancestor_matcher.taxon_concepts.map(&:full_name)).to eq(
      [ 'Aaa', 'Aaab' ]
      )
    end
  end
  context 'when taxon concept scope applied' do
    let(:ancestor_matcher_params) do
      SearchParams.new(
        taxonomy: { id: taxonomy.id },
        taxon_concept: { id: taxon_concept4.id, scope: :ancestors },
        scientific_name: 'A'
      )
    end
    let(:ancestor_matcher) do
      TaxonConceptPrefixMatcher.new ancestor_matcher_params
    end

    specify do
      expect(ancestor_matcher.taxon_concepts.map(&:full_name)).to eq(
      [ 'Aaa', 'Aab', 'Aac' ]
      )
    end

    let(:descendant_matcher_params) do
      SearchParams.new(
        taxonomy: { id: taxonomy.id },
        taxon_concept: { id: taxon_concept2.id, scope: :descendants },
        scientific_name: 'A'
      )
    end
    let(:descendant_matcher) do
      TaxonConceptPrefixMatcher.new descendant_matcher_params
    end

    specify do
      expect(descendant_matcher.taxon_concepts.map(&:full_name)).to eq(
      [ 'Aaab', 'Aab', 'Abb' ]
      )
    end
  end
end
