require 'spec_helper'

describe Api::V1::TaxonConceptsController do
  context 'GET index' do
    include_context 'Boa constrictor'

    it 'logs with Ahoy with different parameters' do
      expect do
        get :index, params: { taxonomy: 'cites_eu', taxon_concept_query: 'stork', geo_entity_scope: 'cites', page: 1 }
      end.to change { Ahoy::Event.count }.by(1)
      expect(Ahoy::Event.last.visit_id).to_not be(nil)

      expect do
        get :index, params: { taxonomy: 'cites_eu', taxon_concept_query: 'dolphin', geo_entity_scope: 'cites', page: 1 }
      end.to change { Ahoy::Event.count }.by(1)
      expect(@ahoy_event1).to eq(@ahoy_event2)
    end

    it 'returns search suggestions when searching for typos' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'costrictor' }

      expect(response.body).to have_json_size(0).at_path(
        'taxon_concepts'
      )

      expect(response.body).to be_json_eql(
        [ { matched_name: 'constrictor' } ].to_json
      ).at_path(
        'meta/search_suggestions'
      )
    end

    it 'search suggestions are case-insensitive' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'Costrictor' }

      expect(response.body).to have_json_size(0).at_path(
        'taxon_concepts'
      )

      expect(response.body).to be_json_eql(
        [ { matched_name: 'constrictor' } ].to_json
      ).at_path(
        'meta/search_suggestions'
      )
    end

    it 'search suggestions are accent-insensitive' do
      get :index, params: { taxonomy: 'CITES', taxon_concept_query: 'kralowsky' }

      expect(response.body).to have_json_size(0).at_path(
        'taxon_concepts'
      )

      expect(response.body).to be_json_eql(
        [ { matched_name: 'kralovsky' } ].to_json
      ).at_path(
        'meta/search_suggestions'
      )
    end
  end

  context 'GET show' do
    context 'Minimal taxon' do
      let!(:taxon_concept) do
        create(:taxon_concept)
      end
      let!(:m_taxon_concept) do
        taxon_concept.m_taxon_concept
      end

      it 'Serialises a minimal taxon correctly' do
        get :show, params: { id: taxon_concept.id }

        response_body = parse_json(response.body)

        # Make sure we have the correct taxon
        expect(
          response_body['taxon_concept']['full_name']
        ).to eq(
          taxon_concept.full_name
        )

        # We expect the response to be a superset of the following:
        expected = {
          'id' => taxon_concept.id,
          'parent_id' => taxon_concept.parent_id,
          'full_name' => taxon_concept.full_name,
          'author_year' => nil,
          'standard_references' => [],
          'common_names' => [],
          'distributions' => [],
          'subspecies' => [],
          'distribution_references' => [],
          'name_status' => 'A',
          'nomenclature_note_en' => nil,
          'nomenclature_notification' => false,
          'cites_listing' => nil,
          'eu_listing' => nil,
          'accepted_names' => [],
          'synonyms' => [],
          'references' => [],
          'cites_quotas' => [],
          'cites_suspensions' => [],
          'cites_listings' => [],
          'eu_listings' => [],
          'eu_decisions' => [],
          'cites_processes' => []
        }

        expect(
          response_body['taxon_concept'].slice(*(expected.keys))
        ).to eq(expected)
      end
    end

    context 'Taxon with CITES Processes' do
      let!(:taxon_concept) do
        create(
          :taxon_concept,
        )
      end

      let!(:cites_rst_process) do
        create(
          :cites_rst_process,
          taxon_concept: taxon_concept
        )
      end

      it 'Serialises a minimal taxon correctly' do
        get :show, params: { id: taxon_concept.id }

        response_body = parse_json(response.body)

        # Make sure we have the correct taxon
        expect(
          response_body['taxon_concept']['full_name']
        ).to eq(
          taxon_concept.full_name
        )

        # Check that CITES RST processes are included in the response
        expect(
          response_body['taxon_concept']['cites_processes'].length
        ).to eq(
          1
        )
      end
    end
  end
end
