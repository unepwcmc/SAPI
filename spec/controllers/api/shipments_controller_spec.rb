require 'spec_helper'

def test_endpoints_with(test_cases_by_endpoint)
  test_cases_by_endpoint.entries.map do |controller_endpoint, test_cases|
    describe "GET #{controller_endpoint}" do
      test_cases.map do |test_case|
        test_endpoint_with(
          {
            controller_endpoint:,
            **test_case
          }
        )
      end
    end
  end
end

def test_endpoint_with(test_case)
  expected_status = test_case[:expected_status] || :success
  request_params = test_case[:params] || {}
  params_description =
    if request_params.empty?
      'with no params'
    else
      "with params #{request_params.to_json}"
    end

  it "returns HTTP #{expected_status} #{params_description}" do
    get test_case[:controller_endpoint], format: :json, params: request_params

    expect(response).to have_http_status(expected_status)
  end
end

describe Api::V1::ShipmentsController do
  include_context 'Shipments'

  before do
    SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
  end

  # rubocop:disable RSpec/EmptyExampleGroup
  # test_endpoint_with provides the `it`

  test_endpoints_with(
    {
      chart_query: [ {} ],
      grouped_query: [ {} ],
      search_query: [ {} ],
      country_query: [
        { params: { group_by: %w[species taxonomy] } }
      ],
      over_time_query: [
        { params: { group_by: %w[species taxonomy] } }
      ],
      aggregated_over_time_query: [
        { params: { group_by: %w[species taxonomy] } }
      ]
    }
  )

  # TODO: download_data, search_download_data, search_download_all_data
end
