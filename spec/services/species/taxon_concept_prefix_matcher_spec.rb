require 'spec_helper'
describe Species::TaxonConceptPrefixMatcher do
  include_context 'Boa constrictor'
  describe :results do
    context 'when searching by common name' do
      context 'when searching by hyphenated common name' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'red-t',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to include(@species_ac) }
      end

      context 'when searching by hyphenated common name without hyphens' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'red t',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to include(@species_ac) }
      end

      context 'when searching by part of hyphenated common name' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'tailed',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to include(@species_ac) }
      end
    end

    context 'when searching by scientific name' do
      context 'when regular query' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'boa',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to include(@species_ac) }
      end

      context 'when malicious query' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'boa\'',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to be_empty }
      end

      context 'when leading whitespace' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: ' boa',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to include(@species_ac) }
      end

      context 'when trailing whitespace' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'boa ',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to include(@species_ac) }
      end

      context 'when implicitly listed subspecies' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'boa constrictor',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).not_to include(@subspecies2_ac) }
      end

      context 'when explicitly listed subspecies' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'boa constrictor',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to include(@subspecies1_ac) }
      end

      context 'when implicitly listed higher taxon (without an explicitly listed ancestor)' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'serpentes',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to include(@order_ac) }
      end

      context 'when explicitly listed higher taxon' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'boidae',
              ranks: []
            }
          )
        end

        specify { expect(subject.results).to include(@family_ac) }
      end
      # check ranks filtering
      context 'when explicitly listed higher taxon but ranks expected FAMILY' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'boidae',
              ranks: [ 'FAMILY' ],
              visibility: :trade
            }
          )
        end

        specify { expect(subject.results).to include(@family_ac) }
      end

      context 'when explicitly listed higher taxon but ranks expected SPECIES' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'boidae',
              ranks: [ 'SPECIES' ],
              visibility: :trade
            }
          )
        end

        specify { expect(subject.results).to be_empty }
      end

      context 'when searching for name that matches Species and Subspecies but  ranks expected SUBSPECIES' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'boa constrictor',
              ranks: [ 'SUBSPECIES' ],
              visibility: :trade
            }
          )
        end

        specify do
          expect(subject.results).not_to include(@species_ac)
          expect(subject.results).to include(@subspecies1_ac)
        end
      end
    end
  end
end
