require 'spec_helper'

describe CitesTrade::ShipmentsController do
  include_context 'Shipments'

  describe 'GET index' do
    before { SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings }

    context 'serializer' do
      it 'returns comptab export when report_type invalid' do
        get :index, params: {
          filters: {
            report_type: 'raw'
          }, format: :json
        }
        expect(response.body).to have_json_path('shipment_comptab_export')
      end

      it 'returns comptab export when report_type = comptab' do
        get :index, params: {
          filters: {
            report_type: 'comptab'
          }, format: :json
        }
        expect(response.body).to have_json_path('shipment_comptab_export')
      end

      it 'returns gross net export when report_type = gross_exports' do
        get :index, params: {
          filters: {
            report_type: 'gross_exports'
          }, format: :json
        }
        expect(response.body).to have_json_path('shipment_gross_net_export')
      end
    end

    it 'returns all comptab shipments' do
      get :index, format: :json
      expect(response.body).to have_json_size(7).at_path('shipment_comptab_export/rows')
    end

    it 'returns all gross_exports shipments' do
      get :index, params: {
        filters: {
          report_type: 'gross_exports',
          time_range_start: 2012,
          time_range_end: 2014
        }, format: :json
      }
      expect(response.body).to have_json_size(5).at_path('shipment_gross_net_export/rows')
    end

    it 'treats params.$key as params.filters.$key' do
      get :index, params: {
        report_type: 'gross_exports',
        time_range_start: 2012,
        time_range_end: 2014,
        format: :json
      }

      expect(response.body).to have_json_size(5).at_path('shipment_gross_net_export/rows')
    end

    it 'does not throw an error if filters is the empty string' do
      get :index, params: { filters: '' }, format: :json

      expect(response.body).to have_json_size(7).at_path('shipment_comptab_export/rows')
    end

    it 'returns genus & species shipments when searching by genus' do
      get :index, params: {
        filters: {
          taxon_concepts_ids: [ @animal_genus.id ],
          selection_taxon: 'taxonomic_cascade'
        }, format: :json
      }
      expect(response.body).to have_json_size(2).at_path('shipment_comptab_export/rows')
    end

    it 'returns family, genus & species shipments when searching by family' do
      get :index, params: {
        filters: {
          taxon_concepts_ids: [ @animal_family.id ],
          selection_taxon: 'taxonomic_cascade'
        }, format: :json
      }
      expect(response.body).to have_json_size(3).at_path('shipment_comptab_export/rows')
    end

    it 'returns genus shipments when searching by taxon' do
      get :index, params: {
        filters: {
          taxon_concepts_ids: [ @animal_genus.id ],
          selection_taxon: 'taxon'
        }, format: :json
      }
      expect(response.body).to have_json_size(0).at_path('shipment_comptab_export/rows')
    end
  end
end
