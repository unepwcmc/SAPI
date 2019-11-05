class Trade::TradePlusFilters
  ATTRIBUTES = %w[importer exporter origin term
                  source purpose unit].freeze


  def response_ordering(response)
    result = {}
    grouped = response.group_by { |r| r['attribute_name'] }
    grouped.each do |k, v|
      _v = []
      case k
      when 'sources', 'purposes'
        v.map do |value|
          value = JSON.parse(value['data'])
          value['id'], value['name'] = 'unreported', 'Unreported' if value['id'].nil?
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
          value['id'], value['name'] = value['id'].capitalize, value['name'].capitalize
          _v << value
        end
        _v
      else
        _v = v.map { |value| JSON.parse(value['data']) }
      end
      result[k] = _v.sort_by { |i| i['name'].to_s.downcase }
    end
    result
  end

  def query
    <<-SQL
      SELECT *
      FROM (#{new_inner_query}) AS s
    SQL
  end

  def old_query
    <<-SQL
     WITH data AS (
       SELECT #{select_query}
       FROM trade_plus_complete_mview
     )
     SELECT ROW_TO_JSON(t) AS filters
     FROM (
       SELECT #{inner_query}
       FROM data
     ) t
   SQL
  end

  def select_query
    query= []
    ATTRIBUTES.each do |attr|
      query << "#{attr}" << "#{attr}_id"
      query << "#{attr}_iso" if ['exporter', 'importer', 'origin'].include? attr
    end
    query << 'group_name' << 'year' << 'taxon_name' << 'taxon_id' << 'appendix'
    query.join(',')
  end

  def inner_query
    query = ''
    ATTRIBUTES.each do |attr|
      if %w[term unit].include? attr
        query << "json_agg(DISTINCT(json_build_object('name', #{attr}, 'id', #{attr})::jsonb)) AS #{attr.pluralize},"
      elsif %w[importer exporter origin].include? attr
        query << "json_agg(
                       DISTINCT(
                         json_build_object('name', #{attr}, 'id', #{attr}_id, 'iso2', #{attr}_iso)::jsonb
                       )
                     )
                    AS #{attr.pluralize},
                   "
      else
        query << "json_agg(
                       DISTINCT(
                         json_build_object('name', #{attr}, 'id', #{attr}_id)::jsonb
                       )
                     )
                    AS #{attr.pluralize},
                   "
      end

    end
    query << "json_agg(DISTINCT(json_build_object('name', taxon_name, 'id', taxon_id)::jsonb)) AS taxa,"
    query << "json_agg(DISTINCT(json_build_object('name', group_name, 'id', group_name)::jsonb)) AS taxonomic_groups,"
    query << "json_agg(DISTINCT(json_build_object('name', year, 'id', year)::jsonb)) AS years,"
    query << "json_agg(DISTINCT(json_build_object('name', appendix, 'id', appendix)::jsonb)) AS appendix"
    query
  end

  def new_inner_query
    query = []
    ATTRIBUTES.each do |attr|
      if %w[term unit].include? attr
        query << sub_query([attr, attr], attr.pluralize)
      elsif %w[importer exporter origin].include? attr
        query << sub_query([attr, "#{attr}_id", "#{attr}_iso"], attr.pluralize)
      else
        query << sub_query([attr, "#{attr}_id"], attr.pluralize)
      end
    end
    query << sub_query(['taxon_name', 'taxon_id'], 'taxa')
    query << sub_query(['group_name', 'group_name'], 'taxonomic_groups')
    query << sub_query(['year', 'year'], 'years')
    query << sub_query(['appendix', 'appendix'], 'appendix')

    <<-SQL
      #{query.join(' UNION ') }
    SQL
  end

  def sub_query(attributes, as)
    json_values = "'name',#{attributes[0]},'id',#{attributes[1]}"
    json_values << ",'iso2',#{attributes[2]}" if attributes.length == 3
    group_by_attrs = attributes.uniq.join(',')
    "SELECT '#{as}' AS attribute_name, json_build_object(#{json_values})::jsonb AS data FROM #{table_name} #{group_by(group_by_attrs)}"
  end

  def table_name
    'trade_plus_complete_mview'
  end

  def group_by(column_names)
    "GROUP BY #{column_names}"
  end

  def example_query
    <<-SQL
      SELECT json_build_object('name', taxon_name, 'id', taxon_id)::jsonb AS taxa FROM trade_plus_complete_mview GROUP BY taxon_name, taxon_id
      UNION
      SELECT json_build_object('name', group_name, 'id', group_name)::jsonb AS taxonomic_groups FROM trade_plus_complete_mview GROUP BY group_name
      UNION
      SELECT json_build_object('name', year, 'id', year)::jsonb AS years FROM trade_plus_complete_mview GROUP BY year
      UNION
      SELECT json_build_object('name', appendix, 'id', appendix)::jsonb AS appendix FROM trade_plus_complete_mview GROUP BY appendix
    SQL
  end
end
