
class Trade::TradePlusFilters
  attr_reader :locale

  # We are composing SQL with comments, so line breaks are important.
  # rubocop:disable Rails/SquishedSQLHeredocs

  ATTRIBUTES = %w[
    importer exporter origin term
    source purpose unit year appendix
  ].freeze

  def initialize(locale)
    @locale = locale
  end

  def response_ordering(response)
    result = {}
    grouped = response.group_by { |r| r['attribute_name'] }

    grouped.each do |k, v|
      values = format_values(k, v)
      result[k] = values.sort_by { |i| ordering(k, i['name']) }

      # this is to push the "unreported" value at the bottom of the list
      result[k] = values.partition { |value| value['id'] != 'unreported' }.reduce(:+) if [ 'sources', 'purposes' ].include?(k)
    end

    result
  end

  ##
  # This query has been structured carefully to optimise it for performance,
  # specifically to avoid seq scans on the very large trade_plus_complete_mview
  # matview, and instead make the most possible use of index-only scans.
  #
  # A more conventional approach using GROUP BY instead of WHERE EXISTS
  # previously took over 10m, which meant that we had to reject the first
  # request for trade data, kick off a worker to calculate it, and put the
  # result into a shared cache.
  #
  # Therefore when making changes here, please test thoroughly!
  #
  # There is a small downside to this approach, which is that if the contents of
  # the original tables like geo_entities, trade_codes etc. change, then the
  # results here might be slightly out of sync with trade_plus_complete_mview,
  # until it is refreshed.
  def query
    <<-SQL
      WITH country_data AS (
        SELECT id, name_en, name_es, name_fr, iso_code2
        FROM geo_entities
        WHERE geo_entity_type_id IN (1,4,7) -- (1,4,7) this is to include both countries, territories and trade entities
        AND id NOT IN (
          -- this is to exclude
          218, -- Taiwan (included into China)
          221  -- Sudan prior to secession
        )
        -- The following have null or empty iso2 codes:
        --
        -- North Atlantic stock
        -- South Atlantic stock
        -- All stocks
        -- Indian Ocean stock
        -- Mediterranean stock
        --
        -- others may follow
        AND iso_code2 != ''
      )
      SELECT * FROM (
        SELECT
          'importers' AS attribute_name,
          json_build_object(
            'name', g.name_#{@locale},
            'id',   g.id,
            'iso2', g.iso_code2
          )::jsonb AS "data"
        FROM geo_entities g
        WHERE EXISTS (
          SELECT importer_id
          FROM trade_plus_complete_mview
          WHERE importer_id = g.id
        )
      UNION
        SELECT
          'exporters' AS attribute_name,
          json_build_object(
            'name', g.name_#{@locale},
            'id',   g.id,
            'iso2', g.iso_code2
          )::jsonb AS "data"
        FROM geo_entities g
        WHERE EXISTS (
          SELECT exporter_id
          FROM trade_plus_complete_mview
          WHERE exporter_id = g.id
        )
      UNION
        SELECT
          'origins' AS attribute_name,
          json_build_object(
            'name', g.name_#{@locale},
            'id',   g.id,
            'iso2', g.iso_code2
          )::jsonb AS "data"
        FROM geo_entities g
        WHERE EXISTS (
          SELECT origin_id
          FROM trade_plus_complete_mview
          WHERE origin_id = g.id
        )
      UNION
        SELECT
          'terms' AS attribute_name,
          json_build_object(
            'name', t.name_#{@locale},
            'id',   t.id,
            'code', t.code
          )::jsonb AS "data"
        FROM trade_codes t
        WHERE EXISTS (
          SELECT term_id
          FROM trade_plus_complete_mview
          WHERE term_id = t.id
        )
      UNION
        SELECT
          'sources' AS attribute_name,
          json_build_object(
            'name', t.name_#{@locale},
            'id',   t.id,
            'code', t.code
          )::jsonb AS "data"
        FROM trade_codes t
        WHERE EXISTS (
          SELECT source_id
          FROM trade_plus_complete_mview
          WHERE source_id = t.id
        )
      UNION
        SELECT
          'purposes' AS attribute_name,
          json_build_object(
            'name', t.name_#{@locale},
            'id',   t.id,
            'code', t.code
          )::jsonb AS "data"
        FROM trade_codes t
        WHERE EXISTS (
          SELECT purpose_id
          FROM trade_plus_complete_mview
          WHERE purpose_id = t.id
        )
      UNION
        SELECT
          'units' AS attribute_name,
          json_build_object(
            'name', t.name_#{@locale},
            'id',   t.id,
            'code', t.code
          )::jsonb AS "data"
        FROM trade_codes t
        WHERE EXISTS (
          SELECT unit_id
          FROM trade_plus_complete_mview
          WHERE unit_id = t.id
        )
      UNION
        SELECT
          'years' AS attribute_name,
          json_build_object(
            'name', t.year,
            'id',   t.year
          )::jsonb AS "data"
        FROM (
          SELECT generate_series(min(year), max(year)) AS "year"
          FROM trade_plus_complete_mview
        ) t
        WHERE EXISTS (
          SELECT "year"
          FROM trade_plus_complete_mview
          WHERE "year" = t."year"
        )
      UNION
        SELECT
        'appendixes' AS attribute_name,
        json_build_object(
          'name', l.abbreviation,
          'id',   l.abbreviation
        )::jsonb AS "data"
        FROM species_listings l
        WHERE EXISTS (
          SELECT appendix
          FROM trade_plus_complete_mview
          WHERE l.abbreviation = appendix
        )
      UNION
        SELECT
          'taxonomic_groups' AS attribute_name,
          json_build_object(
            'name', g.name_#{@locale},
            'id',   g.name_en
          )::jsonb AS "data"
          FROM trade_taxon_groups g
          WHERE EXISTS (
            SELECT group_code
            FROM trade_plus_complete_mview
            WHERE group_code = g.code
          )
      UNION
        SELECT
          'countries' AS attribute_name,
          json_build_object(
            'name', g.name_#{@locale},
            'id',   g.id,
            'iso2', g.iso_code2
          )::jsonb AS "data"
        FROM country_data g
      ) AS s
      ORDER BY attribute_name
    SQL
  end


private

  def format_values(key, values)
    case key
    when 'sources', 'purposes'
      values.map do |value|
        JSON.parse(value['data'])
      end.sort_by do |value|
        value['code']
      end.append(
        {
          'id' => 'unreported',
          'code' => 'UNR',
          'name' => I18n.t('tradeplus.unreported')
        }
      )
    when 'units'
      values.map do |value|
        value = JSON.parse(value['data'])

        value['name'] = I18n.t(
          "tradeplus.units.#{value['name']}",
          default: nil
        )

        value
      end.select do |value|
        # Only show units in the translations file. This is because there are
        # some rare shipments with odd units like sides which we don't care
        # about filtering for.
        value['name']
      end.append(
        {
          'id' => 'items',
          'code' => 'NAR',
          'name' => I18n.t('tradeplus.units.items')
        }
      )
    when 'origins'
      values.map do |value|
        JSON.parse(value['data'])
      end.append(
        {
          'id' => 'direct',
          'iso2' => I18n.t('tradeplus.direct'),
          'name' => I18n.t('tradeplus.direct')
        }
      )
    when 'terms'
      values.map do |value|
        value = JSON.parse(value['data'])
        value['name'].capitalize!

        value
      end
    else
      values.map do |value|
        JSON.parse(value['data'])
      end
    end
  end

  def ordering(attribute, attribute_value)
    if attribute == 'taxonomic_groups'
      # If there are unexpected attribute values put them at the end
      taxonomy_ordering.index(attribute_value) || taxonomy_ordering.length
    elsif attribute == 'units'
      unit_ordering.index(attribute_value) || unit_ordering.length
    else
      attribute_value.to_s.downcase
    end
  end

  def taxonomy_ordering
    I18n.t('tradeplus.taxon_groups').split(',')
  end

  def unit_ordering
    I18n.t('tradeplus.units').values
  end
end
