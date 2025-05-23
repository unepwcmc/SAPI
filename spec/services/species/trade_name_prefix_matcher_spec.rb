require 'spec_helper'
describe Species::TaxonConceptPrefixMatcher do
  before(:each) do
    @accepted_name = create_cites_eu_genus(
      taxon_name: create(:taxon_name, scientific_name: 'Pavona')
    )
    @trade_name = create_cites_eu_species(
      taxon_name: create(:taxon_name, scientific_name: 'Pavona minor'),
      name_status: 'T'
    )
    @status_N_species = create_cites_eu_species(
      taxon_name: create(:taxon_name, scientific_name: 'Paradisaea'),
      parent: create_cites_eu_genus(
        taxon_name: create(:taxon_name, scientific_name: 'Vidua')
      ),
      name_status: 'N'
    )
    create(
      :taxon_relationship,
      taxon_concept: @accepted_name,
      other_taxon_concept: @trade_name,
      taxon_relationship_type: trade_name_relationship_type
    )
    create_cites_I_addition(taxon_concept: @accepted_name)
    SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
    @accepted_name_ac = MAutoCompleteTaxonConcept.find(@accepted_name.id)
    @trade_name_ac = MAutoCompleteTaxonConcept.find(@trade_name.id)
    @status_N_species_ac = MAutoCompleteTaxonConcept.find(@status_N_species.id)
  end
  describe :results do
    context 'when searching for status N species' do
      context 'when trade visibility' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'Vidua',
              ranks: [],
              visibility: :trade
            }
          )
        end
        specify { expect(subject.results).to include(@status_N_species_ac) }
      end
      context 'when trade internal visibility' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'Vidua',
              ranks: [],
              visibility: :trade_internal
            }
          )
        end
        specify { expect(subject.results).to include(@status_N_species_ac) }
      end
      context 'when speciesplus visibility' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'Vidua',
              ranks: []
            }
          )
        end
        specify { expect(subject.results).not_to include(@status_N_species_ac) }
      end
    end
    context 'when searching for trade name' do
      context 'when trade visibility' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'Pavona',
              ranks: [],
              visibility: :trade
            }
          )
        end
        specify { expect(subject.results).not_to include(@trade_name_ac) }
        specify { expect(subject.results).to include(@accepted_name_ac) }
      end
      context 'when trade internal visibility' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'Pavona',
              ranks: [],
              visibility: :trade_internal
            }
          )
        end
        specify { expect(subject.results).to include(@trade_name_ac) }
        specify { expect(subject.results).to include(@accepted_name_ac) }
      end
      context 'when speciesplus visibility' do
        subject do
          Species::TaxonConceptPrefixMatcher.new(
            {
              taxon_concept_query: 'Pavona',
              ranks: []
            }
          )
        end
        specify { expect(subject.results).not_to include(@trade_name_ac) }
        specify { expect(subject.results).to include(@accepted_name_ac) }
      end
    end
  end
end
