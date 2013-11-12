class Trade::Filter
  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def results
    @query.limit(@options[:per_page]).
      offset(@options[:per_page] * (@options[:page] - 1)).all
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
    @query = Trade::Shipment.includes([
      :exporter, :importer, :country_of_origin, :purpose,
      :source, :term, :unit, :country_of_origin_permit,
      :import_permit, :export_permits, :taxon_concept
    ]).order('year DESC')

    unless @taxon_concepts_ids.empty?
      @query = @query.where(:taxon_concept_id => @taxon_concepts_ids)
    end

    unless @appendices.empty?
      @query = @query.where(:appendix => @appendices)
    end
    
    unless @time_range_start == 0 || @time_range_end == 0
      @query = @query.where(:year => @time_range_start..@time_range_end)
    end

    unless @terms_ids.empty?
      @query = @query.where(:term_id => @terms_ids)
    end

    unless @units_ids.empty?
      @query = @query.where(:unit_id => @units_ids)
    end

    unless @purposes_ids.empty?
      @query = @query.where(:purpose_id => @purposes_ids)
    end

    unless @sources_ids.empty?
      @query = @query.where(:source_id => @sources_ids)
    end

    unless @importers_ids.empty?
      @query = @query.where(:importer_id => @importers_ids)
    end

    unless @exporters_ids.empty?
      @query = @query.where(:exporter_id => @exporters_ids)
    end

    unless @countries_of_origin_ids.empty?
      @query = @query.where(:country_of_origin_id => @countries_of_origin_ids)
    end

    unless @reporter_type.nil?
      if @reporter_type == 'E'
        @query = @query.where(:reported_by_exporter => true)
      elsif @reporter_type == 'I'
        @query = @query.where(:reported_by_exporter => false)
      else
      end
    end

    unless @permits_ids.empty?
      @query = @query.where("import_permit_id = ? or country_of_origin_permit_id = ?",  @permits_ids , @permits_ids)
    end

    unless @quantity.nil?
      @query = @query.where(:quantity => @quantity)
    end

















  end

end
