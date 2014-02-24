class Trade::Filter
  attr_reader :page, :per_page, :query
  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def results
    @query.limit(@per_page).
      offset(@per_page * (@page - 1)).all
  end

  def total_cnt
    @query.count
  end

  private

  def initialize_params(options)
    @options = Trade::SearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    @query = Trade::Shipment.order('year DESC').
      preload(:taxon_concept) #includes would override the select clause

    # Id's (array)
    unless @taxon_concepts_ids.empty?
      ancestor_ranks = Rank.in_range(Rank::SPECIES, Rank::KINGDOM)
      taxa = MTaxonConceptFilterByIdWithDescendants.new(nil, @taxon_concepts_ids).
        relation(ancestor_ranks)
      @query = @query.where(:taxon_concept_id => taxa.select(:id).map(&:id))
    end

    unless @appendices.empty?
      @query = @query.where(:appendix => @appendices)
    end

    unless @terms_ids.empty?
      @query = @query.where(:term_id => @terms_ids)
    end

    unless @importers_ids.empty?
      @query = @query.where(:importer_id => @importers_ids)
    end

    unless @exporters_ids.empty?
      @query = @query.where(:exporter_id => @exporters_ids)
    end

    if !@units_ids.empty?
      local_field = "unit_id"
      blank_query = @unit_blank ? "OR unit_id IS NULL" : ""
      @query = @query.where("#{local_field} IN (?) #{blank_query}", @units_ids)
    elsif @unit_blank
      @query = @query.where(:unit_id => nil)
    end

    if !@purposes_ids.empty?
      local_field = "purpose_id"
      blank_query = @purpose_blank ? "OR purpose_id IS NULL" : ""
      @query = @query.where("#{local_field} IN (?) #{blank_query}", @purposes_ids)
    elsif @purpose_blank
      @query = @query.where(:purpose_id => nil)
    end

    if !@sources_ids.empty?
      local_field = "source_id"
      blank_query = @source_blank ? "OR source_id IS NULL" : ""
      @query = @query.where("#{local_field} IN (?) #{blank_query}", @sources_ids)
    elsif @source_blank
      @query = @query.where(:source_id => nil)
    end


    if !@countries_of_origin_ids.empty?
      local_field = "country_of_origin_id"
      blank_query = @country_of_origin_blank ? "OR country_of_origin_id IS NULL" : ""
      @query = @query.where("#{local_field} IN (?) #{blank_query}", @countries_of_origin_ids)
    elsif @country_of_origin_blank
      @query = @query.where(:country_of_origin_id => nil)
    end

    # Other cases

    unless @time_range_start.blank? && @time_range_end.blank?
      if @time_range_start.blank?
        @query = @query.where(["year <= ?", @time_range_end])
      elsif @time_range_end.blank?
        @query = @query.where(["year >= ?", @time_range_start])
      else
        @query = @query.where(:year => @time_range_start..@time_range_end)
      end
    end

    initialize_internal_query if @internal

  end

  def initialize_internal_query
    if @report_type == :raw
      # only use the view for the raw report in admin
      @query = @query.from('trade_shipments_view trade_shipments').
        preload(:reported_taxon_concept) #includes would override the select clause
    end

    if ['I', 'E'].include? @reporter_type
      if @reporter_type == 'E'
        @query = @query.where(:reported_by_exporter => true)
      elsif @reporter_type == 'I'
        @query = @query.where(:reported_by_exporter => false)
      end
    end

    permit_blank_query = 
      'ARRAY_UPPER(import_permits_ids, 1) IS NULL
      OR ARRAY_UPPER(export_permits_ids, 1) IS NULL
      OR ARRAY_UPPER(origin_permits_ids, 1) IS NULL'
    if !@permits_ids.empty?
      @query = @query.where(
        "import_permits_ids::INT[] && ARRAY[:permits_ids]::INT[]
        OR export_permits_ids::INT[] && ARRAY[:permits_ids]::INT[]
        OR origin_permits_ids::INT[] && ARRAY[:permits_ids]::INT[]
        #{@permit_blank ? "OR #{permit_blank_query}" : ''}",
        :permits_ids => @permits_ids
        )
    elsif @permit_blank
      @query = @query.where(permit_blank_query)
    end

    unless @quantity.nil?
      if @quantity == 0
        @query = @query.where('quantity = 0 OR quantity IS NULL')
      else
        @query = @query.where(:quantity => @quantity)
      end
    end

  end

end
