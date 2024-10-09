require 'spec_helper'
describe Species::TaxonConceptPrefixMatcher do
  include_context 'Falconiformes'
  describe :results do
    context 'when searching for hybrid' do
      context 'when trade visibility' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'Falco hybrid',
              ranks: [],
              visibility: :trade
            }
          )
        end
        specify { expect(subject.results).to include(@hybrid_ac) }
      end
      context 'when trade internal visibility' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'Falco hybrid',
              ranks: [],
              visibility: :trade_internal
            }
          )
        end
        specify { expect(subject.results).to include(@hybrid_ac) }
      end
      context 'when speciesplus visibility' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'Falco hybrid',
              ranks: []
            }
          )
        end
        specify { expect(subject.results).to be_empty }
      end
    end
  end
end
