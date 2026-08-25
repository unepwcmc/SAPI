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
    get test_case[:controller_endpoint],
      format: :json,
      params:
        if test_case[:build_params]
          test_case[:build_params].call(self, request_params)
        else
          request_params
        end

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
          {
            terms: %w[ name id code value total_count ],
            sources: %w[ code name id value total_count ],
            exporting: %w[ name iso2 value total_count ],
            importing: %w[ name iso2 value total_count ],
            species: %w[ taxon_name appendix id value total_count ],
            # NB: order_name family_name genus_name taxon_name also available
            # but taxonomic_level defaults to class
            taxonomy: %w[
              id
              name
              value
              kingdom_name
              phylum_name
              class_name
              total_count
            ]
          }.map do |group_by, expected_keys|
            {
              params: {
                grouping_type: 'TradePlusStatic',
                group_by: group_by
              },
              response_attributes: [
                {
                  attribute: :data,
                  description: "be an array of objects with keys #{expected_keys}",
                  satisfies: lambda do |attr_value|
                    attr_value.instance_of?(Array) &&
                      attr_value.all? do |item|
                        item.keys.sort == expected_keys.sort
                      end
                  end
                }
              ]
            }
          end
        ),
        *[
          # check that :downcase works
          {
            params: {
              grouping_type: 'TradePlusStatic',
              term_names: 'CaViar',
              group_by: 'taxonomy'
            },
            response_attributes: [
              {
                attribute: :data,
                description: 'have a single record with a total count of 1',
                satisfies: lambda do |attr_value|
                  attr_value.instance_of?(Array) &&
                    attr_value.length == 1 &&
                    attr_value[0]['total_count'] == 1
                end
              }
            ]
          }
        ],
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
        *(
          %w[species terms sources taxonomy exporting importing].map do |group_by|
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
          # Test country_ids parsing
          params: {
            locale: 'en',
            grouping_type: 'TradePlusStatic',
            group_by: 'sources',
            reported_by: 'importer',
            country_ids: '[@portugal.id], [@argentina.id]' # override this
          },
          build_params: lambda do |ctx, original_params|
            {
              **original_params,
              country_ids: [
                # Shipments sets @portugal, argentina
                ctx.instance_values['portugal'].id,
                ctx.instance_values['argentina'].id
              ].join(',')
            }
          end,
          response_attributes: [
            {
              attribute: :data,
              description: 'return three records with codes U, W, nil',
              satisfies: lambda do |attr_value|
                attr_value.instance_of?(Array) &&
                  attr_value.length == 3 &&
                  attr_value.pluck('code').tally == [ 'U', 'W', nil ].tally
              end
            }
          ]
        },
        {
          # Test country_ids accepting an array
          params: {
            locale: 'en',
            grouping_type: 'TradePlusStatic',
            group_by: 'sources',
            reported_by: 'importer',
            country_ids: '[@portugal.id], [@argentina.id]' # override this
          },
          build_params: lambda do |ctx, original_params|
            {
              **original_params,
              country_ids: [
                # Shipments sets @portugal, argentina
                ctx.instance_values['portugal'].id,
                ctx.instance_values['argentina'].id
              ]
            }
          end,
          response_attributes: [
            {
              attribute: :data,
              description: 'return three records with codes U, W, nil',
              satisfies: lambda do |attr_value|
                attr_value.instance_of?(Array) &&
                  attr_value.length == 3 &&
                  attr_value.pluck('code').tally == [ 'U', 'W', nil ].tally
              end
            }
          ]
        }
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
        },
        {
          # Realistic example: Overview - Source over time chart
          params: {
            time_range_start: '2019',
            time_range_end: '2025',
            grouping_type: 'TradePlusStatic',
            group_by: 'sources',
            reported_by: 'exporter',
            unit_id: 'items',
            origin_ids: 'direct',
            limit: '5',
            locale: 'en'
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
      ],

      aggregated_over_time_query: [
        *(
          %w[species taxonomy].map do |group_by|
            {
              params: { group_by: group_by },
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
          end
        )
      ]
    }
  )

  # TODO: download_data, search_download_data, search_download_all_data
end
