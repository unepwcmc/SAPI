require 'spec_helper'

def test_endpoint_with(test_case)
  expected_status = test_case[:expected_status] || :success
  params_description =
    if test_case[:params].empty?
      'with no params'
    else
      "with params #{test_case[:params].to_json}"
    end

  it "returns HTTP #{expected_status} #{params_description}" do
    get :over_time_query, format: :json, params: test_case[:params]

    expect(response).to have_http_status(expected_status)
  end
end

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
    [
      {
        controller_method: :country_query,
        params: {
          group_by: %w[
            species
            taxonomy
          ]
        }
      }
    ].map do |test_case|
      test_endpoint_with test_case
    end
  end

  describe 'GET over_time_query' do
    [
      {
        controller_method: :over_time_query,
        params: {
          group_by: %w[
            species
            taxonomy
          ]
        }
      }
    ].map do |test_case|
      test_endpoint_with test_case
    end
  end

  describe 'GET aggregated_over_time_query' do
    [
      {
        controller_method: :aggregated_over_time_query,
        params: {
          group_by: %w[
            species
            taxonomy
          ]
        }
      }
    ].map do |test_case|
      test_endpoint_with test_case
    end
  end

  # TODO: download_data, search_download_data, search_download_all_data
end
