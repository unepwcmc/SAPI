class Trade::Filter
  attr_reader :page, :per_page, :report_type, :options

  def initialize(options)
    initialize_params(options)
  end

  def query_with_limit
    query.limit(@per_page).
      offset(@per_page * (@page - 1))
  end

  def results
    query_with_limit.order('year DESC').to_a
  end

  def total_cnt
    query.count
  end

  def query
    @query ||= initialize_query
  end

private

  def initialize_params(options)
    @options = Trade::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    draft_query = Trade::Shipment.from("#{@shipments_view} AS trade_shipments")

    unless @taxon_concepts_ids.empty?
      cascading_ranks =
        if @internal || @taxon_with_descendants
          # always cascade if query is coming from the internal and now also public interface
          # the magnificent hack to make sure that queries coming from the public
          # interface cascade to taxon descendants when searching across all taxonomic levels,
          # but only through the 'all_taxa' selector, not 'taxon'
          Rank.in_range(Rank::SPECIES, Rank::KINGDOM)
        else
          # this has to be public interface + search by taxon
          # only cascade for species
          Rank.in_range(Rank::SPECIES, Rank::SPECIES)
        end

      taxon_concepts = MTaxonConcept.where(id: @taxon_concepts_ids)

      taxon_concepts_conditions =
        taxon_concepts.map do |tc|
          [ :id, tc.id ]
        end + taxon_concepts.select do |tc|
          cascading_ranks.include?(tc.rank_name)
        end.map do |tc|
          [ :"#{tc.rank_name.downcase}_id", tc.id ]
        end

      draft_query = draft_query.where(
        taxon_concepts_conditions.map { |c| "taxon_concept_#{c[0]} = #{c[1]}" }.join(' OR ')
      )
    end

    unless @reported_taxon_concepts_ids.empty?
      cascading_ranks = Rank.in_range(Rank::SPECIES, Rank::KINGDOM)
      reported_taxon_concepts = MTaxonConcept.where(id: @reported_taxon_concepts_ids)
      reported_taxon_concepts_conditions =
        reported_taxon_concepts.map do |tc|
          [ :id, tc.id ]
        end + reported_taxon_concepts.select do |tc|
          cascading_ranks.include?(tc.rank_name)
        end.map do |tc|
          [ :"#{tc.rank_name.downcase}_id", tc.id ]
        end

      draft_query = draft_query.where(
        reported_taxon_concepts_conditions.map { |c| "reported_taxon_concept_#{c[0]} = #{c[1]}" }.join(' OR ')
      )
    end

    unless @appendices.empty?
      draft_query = draft_query.where(appendix: @appendices)
    end

    unless @terms_ids.empty?
      draft_query = draft_query.where(term_id: @terms_ids)
    end

    unless @importers_ids.empty?
      importers_ids = sanitize_importer_ids(@importers_ids)
      draft_query = draft_query.where(importer_id: importers_ids)
    end

    unless @exporters_ids.empty?
      exporters_ids = sanitize_exporter_ids(@exporters_ids)
      draft_query = draft_query.where(exporter_id: exporters_ids)
    end

    if !@units_ids.empty?
      local_field = 'unit_id'
      blank_query = @unit_blank ? 'OR unit_id IS NULL' : ''
      draft_query = draft_query.where("#{local_field} IN (?) #{blank_query}", @units_ids)
    elsif @unit_blank
      draft_query = draft_query.where(unit_id: nil)
    end

    if !@purposes_ids.empty?
      local_field = 'purpose_id'
      blank_query = @purpose_blank ? 'OR purpose_id IS NULL' : ''
      draft_query = draft_query.where("#{local_field} IN (?) #{blank_query}", @purposes_ids)
    elsif @purpose_blank
      draft_query = draft_query.where(purpose_id: nil)
    end

    if !@sources_ids.empty?
      if !@internal && (w = Source.find_by(code: 'W')) && @sources_ids.include?(w.id)
        u = Source.find_by(code: 'U')

        @sources_ids << u.id if u

        @source_blank = true
      end

      local_field = 'source_id'
      blank_query = @source_blank ? 'OR source_id IS NULL' : ''
      draft_query = draft_query.where("#{local_field} IN (?) #{blank_query}", @sources_ids)
    elsif @source_blank
      draft_query = draft_query.where(source_id: nil)
    end

    if !@countries_of_origin_ids.empty?
      local_field = 'country_of_origin_id'
      blank_query = @country_of_origin_blank ? 'OR country_of_origin_id IS NULL' : ''
      draft_query = draft_query.where("#{local_field} IN (?) #{blank_query}", @countries_of_origin_ids)
    elsif @country_of_origin_blank
      draft_query = draft_query.where(country_of_origin_id: nil)
    end

    # Other cases
    draft_query = time_range_query(draft_query)

    if @importer_eu_country_ids.present?
      sub_query = eu_country_date_query(@time_range_start, @time_range_end, 'importer')
      draft_query = draft_query.where.not(sub_query) if date_query.present?
    end

    if @exporter_eu_country_ids.present?
      sub_query = eu_country_date_query(@time_range_start, @time_range_end, 'exporter')
      draft_query = draft_query.where.not(sub_query) if sub_query.present?
    end

    if @internal
      initialize_internal_query(draft_query)
    else
      draft_query
    end
  end

  def eu_id
    GeoEntity.where(iso_code2: 'EU').pick(:id)
  end

  def eu_country_ids
    EuCountryDate.pluck(:geo_entity_id)
  end

  def sanitize_exporter_ids(ids)
    return ids unless ids.include?(eu_id)

    ids.delete(eu_id)
    # this is to collect only eu country IDs to apply EU rules query to
    # e.g. EU + Austria we don't have to apply EU rules to Austria
    @exporter_eu_country_ids = eu_country_ids - ids
    (eu_country_ids + ids).uniq
  end

  def sanitize_importer_ids(ids)
    return ids unless ids.include?(eu_id)

    ids.delete(eu_id)
    @importer_eu_country_ids = eu_country_ids - ids
    (eu_country_ids + ids).uniq
  end

  def eu_country_date_query(start_year, end_year, type)
    eu_country_ids = instance_variable_get("@#{type}_eu_country_ids")
    country_query_arr = []
    eu_country_ids.each do |eu_country|
      # check for multiple entries for the same countries(UK might rejoin at some point)
      eu_entry_exit_dates(eu_country).each do |entry_date, exit_date|
        # exclude countries for which we will need to retreive all the shipments
        # within the user selected year range anyway
        exit_date_check = exit_date.nil? ? true : (exit_date > end_year) # workaround to avoid nil > integer
        next if entry_date < start_year && exit_date_check

        exit_year_check = exit_date.nil? ? 'AND TRUE' : "OR year >= #{exit_date}"
        country_query_arr << "(trade_shipments.#{type}_id = #{eu_country} AND (year < #{entry_date} #{exit_year_check}))"
      end
    end
    country_query_arr.join(' OR ')
  end

  def eu_entry_exit_dates(country_id)
    EuCountryDate.where(geo_entity_id: country_id).pluck(:eu_accession_year, :eu_exit_year)
  end

  def time_range_query(original_draft_query)
    unless @time_range_start.blank? && @time_range_end.blank?
      if @time_range_start.blank?
        original_draft_query.where(year: ..@time_range_end)
      elsif @time_range_end.blank?
        original_draft_query.where(year: @time_range_start..)
      else
        original_draft_query.where(year: @time_range_start..@time_range_end)
      end
    else
      original_draft_query
    end
  end

  def initialize_internal_query(original_draft_query)
    draft_query = original_draft_query

    if @report_type == :raw
      # includes would override the select clause
      draft_query = draft_query.preload(:reported_taxon_concept)
    end

    if [ 'I', 'E' ].include? @reporter_type
      if @reporter_type == 'E'
        draft_query = draft_query.where(reported_by_exporter: true)
      elsif @reporter_type == 'I'
        draft_query = draft_query.where(reported_by_exporter: false)
      end
    end

    permit_blank_query =
      <<-SQL.squish
        ARRAY_UPPER(import_permits_ids, 1) IS NULL OR
        ARRAY_UPPER(export_permits_ids, 1) IS NULL OR
        ARRAY_UPPER(origin_permits_ids, 1) IS NULL OR
        ARRAY_UPPER(ifs_permits_ids, 1) IS NULL
      SQL

    if !@permits_ids.empty?
      permit_match_sql =
        <<-SQL.squish
          import_permits_ids::INT[] && ARRAY[:permits_ids]::INT[] OR
          export_permits_ids::INT[] && ARRAY[:permits_ids]::INT[] OR
          origin_permits_ids::INT[] && ARRAY[:permits_ids]::INT[] OR
          ifs_permits_ids::INT[] && ARRAY[:permits_ids]::INT[]
        SQL

      draft_query = draft_query.where(
        if @permit_blank
          "#{permit_match_sql} OR #{permit_blank_query}"
        else
          permit_match_sql
        end,
        permits_ids: @permits_ids
      )
    elsif @permit_blank
      draft_query = draft_query.where(permit_blank_query)
    end

    unless @quantity.nil?
      if @quantity == 0
        draft_query = draft_query.where('quantity = 0 OR quantity IS NULL')
      else
        draft_query = draft_query.where(quantity: @quantity)
      end
    end

    draft_query
  end
end
