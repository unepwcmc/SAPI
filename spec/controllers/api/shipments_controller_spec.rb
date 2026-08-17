require 'spec_helper'

describe Api::V1::ShipmentsController do
  include_context 'Shipments'

  before do
    SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
  end

  describe 'GET chart_query' do
    it 'returns HTTP 200 success with no parameters' do
      get :chart_query, format: :json

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET grouped_query' do
    it 'returns HTTP 200 success with no parameters' do
      get :grouped_query, format: :json

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET search_query' do
    it 'returns HTTP 200 success with no parameters' do
      get :search_query, format: :json

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET country_query' do
    it 'returns HTTP 200 success with no parameters' do
      get :country_query, format: :json

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET over_time_query' do
    it 'returns HTTP 200 success with no parameters' do
      get :over_time_query, format: :json

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET aggregated_over_time_query' do
    it 'returns HTTP 200 success with no parameters' do
      get :aggregated_over_time_query, format: :json

      expect(response).to have_http_status(:success)
    end
  end

  # TODO: download_data, search_download_data, search_download_all_data
end
