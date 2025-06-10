require 'spec_helper'

describe Api::V1::AutoCompleteTaxonConceptsController do
  include_context 'Boa constrictor'

  describe 'GET index' do
    it 'returns 1 result when searching for species name and filtering for rank SPECIES' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'Boa', ranks: [ 'SPECIES' ], visibility: 'trade' }

      expect(response.body).to have_json_size(1).at_path(
        'auto_complete_taxon_concepts'
      )
    end

    it 'returns 1 result when searching for common name' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'Red-tailed' }

      expect(response.body).to have_json_size(1).at_path(
        'auto_complete_taxon_concepts'
      )
    end

    it 'returns 1 result when searching for common name with diacritics' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'hroznýš' }

      expect(response.body).to have_json_size(1).at_path(
        'auto_complete_taxon_concepts'
      )
    end

    it 'returns 1 result when searching for common name without diacritics' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'hroznys' }

      expect(response.body).to have_json_size(1).at_path(
        'auto_complete_taxon_concepts'
      )
    end

    it 'returns 1 result when searching for common name with wrong accents' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'hróznýs' }

      expect(response.body).to have_json_size(1).at_path(
        'auto_complete_taxon_concepts'
      )
    end

    it 'returns 1 result when searching for second word of common name' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'královský' }

      expect(response.body).to have_json_size(1).at_path(
        'auto_complete_taxon_concepts'
      )

      # Should match both CZ and SK names
      expect(response.body).to have_json_size(2).at_path(
        'auto_complete_taxon_concepts/0/matching_names'
      )
    end

    it 'returns 1 result when searching for part of common name' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'álovský' }

      expect(response.body).to have_json_size(1).at_path(
        'auto_complete_taxon_concepts'
      )
    end

    it 'returns no results when searching for single letter' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'B' }

      expect(response.body).to have_json_size(0).at_path(
        'auto_complete_taxon_concepts'
      )
    end

    it 'returns results when searching single Chinese ideogram' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: '红' }

      expect(response.body).to have_json_size(1).at_path(
        'auto_complete_taxon_concepts'
      )
    end

    it 'returns results when searching single, non-initial Chinese ideogram' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: '蚺' }

      expect(response.body).to have_json_size(1).at_path(
        'auto_complete_taxon_concepts'
      )
    end

    it 'returns 3 results when searching for species name and not filtering by rank' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'Boa' }

      expect(response.body).to have_json_size(3).at_path(
        'auto_complete_taxon_concepts'
      )
    end
  end
end
