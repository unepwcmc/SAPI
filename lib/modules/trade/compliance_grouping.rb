class Trade::ComplianceGrouping
  attr_reader :query

  # Allowed attributes
  ATTRIBUTES = {
    id: 'id',
    year: 'year',
    appendix: 'appendix',
    importer: 'importer',
    importer_iso: 'importer_iso',
    importer_id: 'importer_id',
    exporter: 'exporter',
    exporter_iso: 'exporter_iso',
    exporter_id: 'exporter_id',
    term: 'term',
    term_id: 'term_id',
    unit: 'unit',
    purpose: 'purpose',
    source: 'source',
    taxon_name: 'taxon_name',
    genus_name: 'genus_name',
    family_name: 'family_name',
    class_name: 'class_name',
    issue_type: 'issue_type',
    taxon_concept_id: 'taxon_concept_id'
  }

  GROUPING_ATTRIBUTES = {
    category: ['issue_type'],
    commodity: ['term', 'term_id'],
    exporting: ['exporter', 'exporter_iso', 'exporter_id'],
    importing: ['importer', 'importer_iso', 'importer_id'],
    species: ['taxon_name', 'appendix', 'taxon_concept_id'],
    taxonomy: [''],
  }

  COUNTRIES = 182.freeze

  TAXONOMIC_GROUPING = 'lib/data/group_conversions.csv'.freeze

  YEARS = (2012..2016).to_a

  # Example usage
  # Group by year considering compliance types:
  # Trade::ComplianceGrouping.new('year', {attributes: ['issue_type']})
  # Group by importer and limit result to 5 records
  # Trade::ComplianceGrouping.new('importer', {limit: 5})
  def initialize(group, opts={})
    @group = sanitise_group(group)
    @attributes = sanitise_params(opts[:attributes])
    @condition = opts[:condition] || 'TRUE'
    @limit = sanitise_limit(opts[:limit])
    @query = group_query
  end

  def run
    db.execute(@query)
  end

  def shipments
    sql = <<-SQL
      SELECT *
      FROM non_compliant_shipments_view
    SQL
    db.execute(sql)
  end

  def json_by_year(data, params, opts={})
    return data unless data.first["year"]

    # Custom group_by
    years = data.map { |d| d["year"] }.uniq
    json = []
    years.map do |year|
      partials = data.select { |d| d["year"] == year }
      values = partials.map do |partial|
        hash = {}
        opts.each { |key, value| hash.merge!({"#{key}": partial[value]}) }
        hash.merge({
          value: partial['cnt'],
          percent: partial['percent']
        })
      end
      json << ({ "#{year}": values })
    end
    record = {}
    json.each do |d|
      key = d.keys.first
      # Fetch top 5
      record[key] = d[key][0..4]
    end
    record
  end

  # TODO
  # This calculates the number countries who have reported, given a year as input,
  # for a range that goes from year-1 to year+1.
  # At the moment it uses the compliance tables, but it should instead consider
  # all the shipments instead of the non-compliant ones only.
  def countries_reported_range(year)
    years = [year - 1, year, year + 1]
    hash = {}
    years.map do |y|
      data = countries_reported(y)
      hash[year] ||= []
      hash[year] << data
    end
    hash
  end

  def read_taxonomy_conversion
    conversion = {}
    taxonomy = CSV.read(TAXONOMIC_GROUPING, {headers: true})
    taxonomy.each do |csv|
      conversion[csv['group']] ||= []
      data = {
        taxon_name: csv['taxon_name'],
        rank: csv['taxonomic_level']
      }
      conversion[csv['group']] << data
    end
    conversion
  end

  def taxonomic_grouping
    YEARS.map do |year|
      { "#{year}": taxonomic_grouping_per_year(year) }
    end.inject(:merge)
  end

  def taxonomic_grouping_per_year(year)
    conversion = read_taxonomy_conversion

    res = {}
    # Get all the non-compliant shipments in a given year
    query = "SELECT * FROM non_compliant_shipments_view WHERE year = #{year}"
    shipments = db.execute(query)
    # Loop through all the non-compliant shipments
    shipments.map do |shipment|
      # Loop through the conversion hash to consider one group at a time
      conversion.each do |group, groupings|
        # Each group might be about several classes/genuses/species
        groupings.each do |grouping|
          res[group] ||= 0
          # If we are looping through plants but the shipment is about a Timber taxon
          # don't include this in the sum
          next if group == 'Plants' && is_timber?(shipment, conversion["Timber"])
          rank_name = "#{grouping[:rank].downcase}_name"
          res[group] += 1 if shipment[rank_name] == grouping[:taxon_name]
        end
      end
    end
    # Calculate percentages
    shipments_no = shipments.count
    conversion.map do |group, values|
      percent = (res[group].to_f / shipments_no.to_f * 100).round(2)
      {
        taxon: group,
        cnt: res[group],
        percent: percent
      }
    end
  end

  def build_hash(data, params)
    hash, array = {}, []
    if params[:group_by].include?('commodity') || params[:group_by].include?('species')
      hash[params[:year]] = data.map {|d| d.except('year', 'percent')}
    elsif params[:group_by].include?('exporting')
      importers = Trade::ComplianceGrouping.new('year', {attributes: GROUPING_ATTRIBUTES[:importing], condition: "year = #{params[:year]}"}).run
      data, importers = data.group_by {|d| d['exporter']}, importers.group_by {|d| d['importer']}
      sum = importer_exporter_countries(data, importers, params[:year])
      keys = sum.map { |s| s.keys }.flatten
      imp = only_importer_countries(importers, keys, params[:year])
      imp_hash, exp_hash = {}, {}
      imp.each { |el| el.each { |key, value| imp_hash[key] = value } }
      sum.each { |el| el.each { |key, value| exp_hash[key] = value } }
      merged_hash = imp_hash.merge(exp_hash)
      merged_hash =
        merged_hash.map do |k, v|
          { "#{k}": merged_hash[k].merge(percentage: (v[:cnt]*100.0/v[:total_cnt]).round(2)) }
        end
      merged_hash.each do |country|
        country.values.first.merge!(country: country.keys.first.to_s)
        array << country.values.first
      end
      hash[params[:year]] = array
    end
    hash
  end

  def filter(data, params)
    if params[:filter].present?

      if params[:group_by].include?('commodity')
        data = data[params[:year]].delete_if { |d| d['term'].index(/#{params[:filter]}/i).nil? }
      elsif params[:group_by].include?('species')
        data = data[params[:year]].delete_if { |d| d['taxon_name'].index(/#{params[:filter]}/i).nil? }
      elsif params[:group_by].include?('exporting')
        data = data[params[:year]].delete_if { |d| d[:country].index(/#{params[:filter]}/i).nil? }
      end

    elsif params[:id].present?

      if params[:group_by].include?('commodity')
        data = data[params[:year]].delete_if { |d| d['term_id'] != params[:id] }
      elsif params[:group_by].include?('species')
        data = data[params[:year]].delete_if { |d| d['taxon_concept_id'] != params[:id] }
      else
        data = data[params[:year]].delete_if { |d| d[:id] != params[:id]  }
      end

    else
      data[params[:year]]
    end
  end

  def filter_download_data(data, params)
    if params[:group_by].include?('commodity')
      data.map { |d| d['term_id'] }
    elsif params[:group_by].include?('species')
      data.map { |d| d['taxon_concept_id'] }
    elsif params[:group_by].include?('exporting')
      data.map { |d| d[:id] }
    end
  end

  private

  def importer_exporter_countries(data, importers, year)
    data.map do |k, v|
      unless importers[k]
        {
          "#{k}": {
            id: v.first['exporter_id'],
            cnt: v.first['cnt'].to_i,
            total_cnt: total_ships_exp_cnt(v.first['exporter_id'], year)
          }
        }
      else
        {
          "#{k}": {
            id: v.first['exporter_id'],
            cnt: v.first['cnt'].to_i + importers[k].first['cnt'].to_i,
            total_cnt: total_ships_exp_cnt(v.first['exporter_id'], year) + total_ships_imp_cnt(importers[k].first['importer_id'], year)
          }
        }
      end
    end
  end

  def only_importer_countries(importers, keys, year)
    importers.map do |k, v|
      unless keys.include?(k.to_sym)
        {
          "#{k}": {
            id: v.first['importer_id'],
            cnt: v.first['cnt'].to_i,
            total_cnt: total_ships_imp_cnt(v.first['importer_id'], year)
          }
        }
      end
    end.compact
  end

  def group_query
    columns = [@group, @attributes].flatten.compact.uniq.join(',')
    <<-SQL
      SELECT #{columns}, COUNT(*) AS cnt, 100.0*COUNT(*)/(SUM(COUNT(*)) OVER (PARTITION BY year)) AS percent
      FROM non_compliant_shipments_view
      WHERE #{@condition}
      GROUP BY #{columns}
      ORDER BY percent DESC
      #{limit}
    SQL
  end

  def countries_reported(year)
    sql = <<-SQL
      SELECT COUNT(*) AS cnt
      FROM(
        (
          SELECT DISTINCT importer AS country, importer_iso AS iso
          FROM non_compliant_shipments_view
          WHERE year = #{year}
        )
        UNION
        (
          SELECT DISTINCT exporter AS country, exporter_iso AS iso
          FROM non_compliant_shipments_view
          WHERE year = #{year}
        )
      ) AS countries
    SQL
    countries_reported = db.execute(sql).first['cnt'].to_i

    sql = <<-SQL
      SELECT COUNT(*) AS cnt
      FROM non_compliant_shipments_view
      WHERE year = #{year}
    SQL
    issues_reported = db.execute(sql).first['cnt'].to_i

    {
      year: year,
      issuesReported: issues_reported,
      countriesReported: countries_reported,
      countriesYetToReport: COUNTRIES-countries_reported
    }
  end

  def is_timber?(shipment, groupings)
    groupings.each do |grouping|
      rank_name = "#{grouping[:rank].downcase}_name"
      return true if shipment[rank_name] == grouping[:taxon_name]
    end
    return false
  end

  def limit
    @limit ? "LIMIT #{@limit}" : ''
  end

  def sanitise_group(group)
    ATTRIBUTES[group.to_sym]
  end

  def sanitise_params(params)
    return nil if params.blank?
    params.map { |p| ATTRIBUTES[p.to_sym] }
  end

  def sanitise_limit(limit)
    limit.is_a?(Integer) ? limit : nil
  end

  def sanitise_condition(condition)
    # TODO
    return nil if condition.blank?
    condition.map do |key, value|
      if value.is_a?(Array)
        "#{ATTRIBUTES[key]} IN (#{value.join(',')})"
      else
        "#{ATTRIBUTES[key]} = #{value}"
      end
    end.join(' AND ')
  end

  def db
    ActiveRecord::Base.connection
  end

  def total_ships_exp_cnt(id, year)
    # TODO retrieve from trade_shipments instead ??
    query_exp = "SELECT COUNT(*) FROM trade_shipments_with_taxa_view WHERE exporter_id = #{id} AND year = #{year}"
    db.execute(query_exp).values.flatten.first.to_i
  end

  def total_ships_imp_cnt(id, year)
    # TODO retrieve from trade_shipments instead ??
    query_imp = "SELECT COUNT(*) FROM trade_shipments_with_taxa_view WHERE importer_id = #{id} AND year = #{year}"
    db.execute(query_imp).values.flatten.first.to_i
  end
end
