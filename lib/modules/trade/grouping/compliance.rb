class Trade::Grouping::Compliance < Trade::Grouping::Base

  # Complete up to current year - 1
  COUNTRIES = {
    2021 => 182,
    2020 => 182,
    2019 => 182,
    2018 => 182,
    2017 => 182,
    2016 => 182,
    2015 => 180,
    2014 => 180,
    2013 => 179,
    2012 => 176,
    2011 => 175
  }.freeze

  def initialize(attributes, opts={})
    super(attributes, opts)
  end

  # TODO
  # This calculates the number countries who have reported, given a year as input,
  # for a range that goes from year-1 to year+1.
  # At the moment it uses the compliance tables, but it should instead consider
  # all the shipments instead of the non-compliant ones only.
  def countries_reported_range(year)
    year = year.to_i
    years = case year
      when 2012
        [year, year + 1]
     when Date.today.year - 1
        [year - 1, year]
      else
        [year - 1, year, year + 1]
      end
    hash = {}
    years.map do |y|
      data = countries_reported(y)
      hash[year] ||= []
      hash[year] << data
    end
    hash
  end

  def taxonomic_grouping(opts={})
    YEARS.map do |year|
      { "#{year}": taxonomic_grouping_per_year(year) }
    end.inject(:merge)
  end

  def taxonomic_grouping_per_year(year)
    conversion = read_taxonomy_conversion

    res = {}
    # Get all the non-compliant shipments in a given year
    query = "SELECT * FROM #{shipments_table} WHERE year = #{year}"
    shipments = db.execute(query)
    return [] unless shipments.first
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
          rank_name = grouping[:rank] == 'Species' ? 'taxon' : grouping[:rank].downcase
          rank_name = "#{rank_name}_name"
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
      _grouping_attributes = Array.new(GROUPING_ATTRIBUTES[:importing]) << 'year'
      importers = Trade::Grouping::Compliance.new(_grouping_attributes, params).run
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
      hash[params[:year]] = array.sort_by { |x| x[:cnt]}.reverse!
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

  def json_by_attribute(data, opts={})
    attribute = sanitise_group(opts[:attribute])

    begin
      raise NoGroupingAttributeError unless attribute
    rescue => e
      attribute = 'year'
      Rails.logger.info(e)
    end

    grouped_data = data.group_by { |d| d[attribute] }
    grouped_data.each do |key, values|
      # Fetch top 5 and rename 'cnt' to 'value'
      grouped_data[key] = values[0..4].each { |v| v['value'] = v.delete('cnt') }
    end
  end

  FILTERING_ATTRIBUTES = {
    time_range_start: 'year',
    time_range_end: 'year',
    year: 'year'
  }.freeze
  def self.filtering_attributes
    FILTERING_ATTRIBUTES
  end

  DEFAULT_FILTERING_ATTRIBUTES = {
    time_range_start: 2012,
    time_range_end: 1.year.ago.year
  }.freeze
  def self.default_filtering_attributes
    DEFAULT_FILTERING_ATTRIBUTES
  end

  GROUPING_ATTRIBUTES = {
    category: ['issue_type'],
    commodity: ['term', 'term_id'],
    exporting: ['exporter', 'exporter_iso', 'exporter_id'],
    importing: ['importer', 'importer_iso', 'importer_id'],
    species: ['taxon_name', 'appendix', 'taxon_concept_id'],
    taxonomy: ['']
  }.freeze
  def self.grouping_attributes
    GROUPING_ATTRIBUTES
  end

  def self.get_grouping_attributes(group, locale=nil)
    super(group) << 'year'
  end

  private

  def shipments_table
    'non_compliant_shipments_view'
  end

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
  }.freeze

  def attributes
    ATTRIBUTES
  end

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
    columns = @attributes.compact.uniq.join(',')
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
          FROM #{shipments_table}
          WHERE year = #{year}
        )
        UNION
        (
          SELECT DISTINCT exporter AS country, exporter_iso AS iso
          FROM #{shipments_table}
          WHERE year = #{year}
        )
      ) AS countries
    SQL
    countries_reported = db.execute(sql).first['cnt'].to_i

    sql = <<-SQL
      SELECT COUNT(*) AS cnt
      FROM #{shipments_table}
      WHERE year = #{year}
    SQL
    issues_reported = db.execute(sql).first['cnt'].to_i
    {
      year: year,
      issuesReported: issues_reported,
      countriesReported: countries_reported,
      countriesYetToReport: COUNTRIES[year]-countries_reported
    }
  end

  def is_timber?(shipment, groupings)
    groupings.each do |grouping|
      rank_name = grouping[:rank] == 'Species' ? 'taxon' : grouping[:rank].downcase
      rank_name = "#{rank_name}_name"
      return true if shipment[rank_name] == grouping[:taxon_name]
    end
    return false
  end

  #def sanitise_condition(condition)
  #  # TODO
  #  return nil if condition.blank?
  #  condition.map do |key, value|
  #    if value.is_a?(Array)
  #      "#{ATTRIBUTES[key]} IN (#{value.join(',')})"
  #    else
  #      "#{ATTRIBUTES[key]} = #{value}"
  #    end
  #  end.join(' AND ')
  #end

  def total_ships_exp_cnt(id, year)
    query_exp = "SELECT COUNT(*) FROM trade_shipments_with_taxa_view WHERE exporter_id = #{id} AND year = #{year}"
    db.execute(query_exp).values.flatten.first.to_i
  end

  def total_ships_imp_cnt(id, year)
    query_imp = "SELECT COUNT(*) FROM trade_shipments_with_taxa_view WHERE importer_id = #{id} AND year = #{year}"
    db.execute(query_imp).values.flatten.first.to_i
  end

  # Used in the base class to not skip taxon_id equality check.
  # It can be skipped by other groupings
  def skip_taxon_id?
    false
  end
end
