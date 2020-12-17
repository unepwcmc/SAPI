module Trade::TradePlusFilters
  extend self

  ATTRIBUTES = %w[importer exporter origin term
                  source purpose unit year appendix].freeze

  TAXONOMY_ORDERING =  ['Mammals', 'Birds', 'Reptiles', 'Amphibians', 'Fish', 'Coral', 'Non-coral invertebrates', 'Plants', 'Timber']
  UNIT_ORDERING = ['m3', 'kg', 'l', 'm', 'Number of items', 'm2']

  def response_ordering(response)
    result = {}
    grouped = response.group_by { |r| r['attribute_name'] }
    grouped.each do |k, v|
      _v = []
      case k
      when 'sources', 'purposes'
        v.map do |value|
          value = JSON.parse(value['data'])
          value['id'], value['name'], value['code'] = 'unreported', 'Unreported', 'UNR' if value['id'].nil?
          _v << value
        end
        _v
      when 'units'
        v.map do |value|
          value = JSON.parse(value['data'])
          value['id'], value['name'] = 'items', 'Number of items' if value['id'].nil?
          _v << value
        end
        _v
      when 'origins'
        v.map do |value|
          value = JSON.parse(value['data'])
          value['id'], value['iso2'], value['name'] = 'direct', 'direct', 'Direct' if value['id'].nil?
          _v << value
        end
        _v
      when 'terms'
        v.map do |value|
          value = JSON.parse(value['data'])
          value['id'], value['name'], value['code'] = value['id'], value['name'].capitalize, value['code']
          _v << value
        end
        _v
      else
        _v = v.map { |value| JSON.parse(value['data']) }
      end
      result[k] = if k == 'taxonomic_groups'
                    _v.sort_by { |i| TAXONOMY_ORDERING.index(i['name']) }
                  elsif k == 'units'
                    _v.sort_by { |i| UNIT_ORDERING.index(i['name']) }
                  else
                    _v.sort_by { |i| i['name'].to_s.downcase }
                  end
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
        SELECT id,name_en,iso_code2
        FROM geo_entities
        WHERE geo_entity_type_id = 1
      )
      SELECT 'countries' AS attribute_name, json_build_object('id', id, 'name', name_en, 'iso2', iso_code2)::jsonb AS data
      FROM country_data
      GROUP BY id,name_en,iso_code2)
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
    query << sub_query(['group_name', 'group_name'], 'taxonomic_groups')
    query << country_query

    <<-SQL
      #{query.join(' UNION ') }
    SQL
  end

  def sub_query(attributes, as)
    json_values = "'name',#{attributes[0]},'id',#{attributes[1]}"
    json_values << ",'iso2',#{attributes[2]}" if attributes.grep(/iso/).present?
    json_values << ",'code',#{attributes[2]}" if attributes.grep(/code/).present?
    group_by_attrs = attributes.uniq.join(',')
    "SELECT '#{as}' AS attribute_name, json_build_object(#{json_values})::jsonb AS data FROM #{table_name} #{group_by(group_by_attrs)}"
  end

  def table_name
    'trade_plus_complete_mview'
  end

  def group_by(column_names)
    "GROUP BY #{column_names}"
  end
end
