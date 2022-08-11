class Trade::TradePlusFilters
  attr_reader :locale

  ATTRIBUTES = %w[importer exporter origin term
                  source purpose unit year appendix].freeze

  LOCALISED_ATTRIBUTES = (ATTRIBUTES - %w[year appendix]).freeze

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
      result[k] = values.partition { |value| value['id'] != 'unreported' }.reduce(:+) if ['sources', 'purposes'].include?(k)
    end
    result
  end

  def query
    <<-SQL
      SELECT *
      FROM (#{inner_query}) AS s
    SQL
  end

  def country_query
    <<-SQL
      (WITH country_data AS (
        SELECT id,name_#{locale},iso_code2
        FROM geo_entities
        WHERE geo_entity_type_id IN (1,4,7) --(1,4,7) this is to include both countries, territories and trade entities
        AND id NOT IN (218,221,277,278,279) --this is to exclude TW(included into CH), Sudan prior secession, North and South Atlantic stock and All stocks

      )
      SELECT 'countries' AS attribute_name, json_build_object('id', id, 'name', name_#{locale}, 'iso2', iso_code2)::jsonb AS data
      FROM country_data
      GROUP BY id,name_#{locale},iso_code2)
    SQL
  end

  def inner_query
    query = []
    ATTRIBUTES.each do |attr|
      if %w[year appendix].include? attr
        query << sub_query([attr, attr], attr.pluralize)
      elsif %w[importer exporter origin].include? attr
        query << sub_query([attr, "#{attr}_id", "#{attr}_iso"], attr.pluralize)
      elsif %w[term source purpose].include? attr
        query << sub_query([attr, "#{attr}_id", "#{attr}_code"], attr.pluralize)
      else
        query << sub_query([attr, "#{attr}_id"], attr.pluralize)
      end
    end
    query << sub_query(["group_name_#{locale}", "group_name_#{locale}"], 'taxonomic_groups')
    query << country_query

    <<-SQL
      #{query.join(' UNION ') }
    SQL
  end

  def sub_query(attributes, as)
    attributes[0] += "_#{locale}" if LOCALISED_ATTRIBUTES.include? attributes[0]
    json_values = "'name',#{attributes[0]},'id',#{attributes[1]}"
    json_values << ",'iso2',#{attributes[2]}" if attributes.grep(/iso/).present?
    json_values << ",'code',#{attributes[2]}" if attributes.grep(/code/).present?
    group_by_attrs = attributes.uniq.join(',')

    # Exclude possible null values for taxonomic groups
    condition = "WHERE #{attributes[0]} IS NOT NULL" if attributes[0] == "group_name_#{locale}"
    <<-SQL
      SELECT '#{as}' AS attribute_name, json_build_object(#{json_values})::jsonb AS data
      FROM #{table_name}
      #{condition}
      #{group_by(group_by_attrs)}
    SQL
  end

  private

  def table_name
    'trade_plus_complete_mview'
  end

  def group_by(column_names)
    "GROUP BY #{column_names}"
  end

  def format_values(key, values)
    case key
    when 'sources', 'purposes'
      values.map do |value|
        value = JSON.parse(value['data'])
        value['id'], value['name'], value['code'] = 'unreported', I18n.t('tradeplus.unreported'), 'UNR' if value['id'].nil?

        value
      end
    when 'units'
      values.map do |value|
        value = JSON.parse(value['data'])
        value['id'] = value['name'] = 'items' if value['id'].nil?
        value['name'] = I18n.t("tradeplus.units.#{value['name']}", default: nil)

        value['name'].nil? ? nil : value
      end.compact
    when 'origins'
      values.map do |value|
        value = JSON.parse(value['data'])
        value['id'], value['iso2'], value['name'] = 'direct', I18n.t('tradeplus.direct'), I18n.t('tradeplus.direct') if value['id'].nil?

        value
      end
    when 'terms'
      values.map do |value|
        value = JSON.parse(value['data'])
        value['id'], value['name'], value['code'] = value['id'], value['name'].capitalize, value['code']

        value
      end
    else
      values.map { |value| JSON.parse(value['data']) }
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
