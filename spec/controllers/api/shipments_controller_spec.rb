require 'spec_helper'

# This test file is aimed at coverage, to make sure the SQL being produced
# executes without error. It doesn't guarantee good behaviour, in particular,
# the shape of the response  and whether the filters supplied to the request
# are correctly applied.

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

    (test_case[:response_attributes].presence || []).map do |test_response_attribute|
      expect(
        assigns(test_response_attribute[:attribute].to_sym)
      ).to satisfy(
        test_response_attribute[:description]
      ) do |attribute_value|
        test_response_attribute[:satisfies].call(attribute_value)
      end
    end
  end
end

describe Api::V1::ShipmentsController do
  include_context 'Shipments'

  before do
    SapiModule::StoredProcedures.rebuild_cites_taxonomy_and_listings
    SapiModule::StoredProcedures.rebuild_trade_plus
  end

  # rubocop:disable RSpec/EmptyExampleGroup
  # test_endpoint_with provides the `it`

  test_endpoints_with(
    {
      chart_query: [ {} ],

      grouped_query: [
        {},
        *(
          %w[species taxonomy terms sources exporting importing].map do |group_by|
            {
              params: {
                grouping_type: 'TradePlusStatic',
                group_by: group_by
              },
              response_attributes: [
                {
                  attribute: :data,
                  description: 'be an array',
                  satisfies: lambda do |attr_value|
                    attr_value.instance_of? Array
                  end
                }
              ]
            }
          end
        ),
        {
          params: {
            time_range_start: '2019',
            time_range_end: '2025',
            grouping_type: 'TradePlusStatic',
            group_by: 'taxonomy',
            grouping: 'taxonomy',
            reported_by: 'exporter',
            unit_id: 'items',
            origin_ids: 'direct',
            taxonomic_level: 'taxon',
            limit: '5',
            locale: 'es'
          }
        },
        {
          params: {
            grouping_type: 'TradePlusStatic',
            group_by: 'importing',
            appendices: 'I',
            reported_by: 'exporter',
            locale: 'en'
          }
        }
      ],

      search_query: [ {} ],

      country_query: [
        { params: { group_by: %w[species taxonomy] } }
      ],

      over_time_query: [
        *(
          # `taxonomy` is not ok for over_time, as we want to group by something
          # otherwise it's way too much data, and also the sql breaks
          %w[species terms sources exporting importing].map do |group_by|
            {
              params: {
                grouping_type: 'TradePlusStatic',
                group_by: group_by
              },
              response_attributes: [
                {
                  attribute: :over_time_data,
                  description: 'be an array',
                  satisfies: lambda do |attr_value|
                    attr_value.instance_of? Array
                  end
                }
              ]
            }
          end
        ),
        *(
          # `taxonomy` is not ok for over_time, as we want to group by something
          # otherwise it's way too much data, and also the sql breaks
          #
          # `category` and `commodity` fail with "Missing list of columns";
          # not sure why.
          %w[exporting importing species].map do |group_by|
            {
              params: {
                # grouping_type: 'Compliance' # implied
                group_by: group_by
              },
              response_attributes: [
                {
                  attribute: :over_time_data,
                  description: 'be an array',
                  satisfies: lambda do |attr_value|
                    attr_value.instance_of? Array
                  end
                }
              ]
            }
          end
        ),
        {
          # Realistic example
          params: {
            locale: 'en',
            grouping_type: 'TradePlusStatic',
            group_by: 'sources',
            reported_by: 'importer',
            unit_id: 'items',
            origin_ids: 'direct',
            time_range_start: '2019',
            time_range_end: '2025',
            limit: '5'
          }
        }
      ],

      aggregated_over_time_query: [
        {
          params: { group_by: %w[species taxonomy] },
          response_attributes: [
            {
              attribute: :aggregated_over_time_data,
              description: 'be an array',
              satisfies: lambda do |attr_value|
                attr_value.instance_of? Array
              end
            }
          ]
        }
      ]
    }
  )

  # TODO: download_data, search_download_data, search_download_all_data
  # TODO: test array/string behaviour of country_ids
end
