class Trade::Filter
  attr_reader :page, :per_page, :query, :report_type, :options
  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def query_with_limit
    @query.limit(@per_page).
      offset(@per_page * (@page - 1))
  end

  def results
    query_with_limit.order('year DESC').to_a
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
    @query = Trade::Shipment.from("#{@shipments_view} trade_shipments")

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
          [:id, tc.id]
        end + taxon_concepts.select do |tc|
          cascading_ranks.include?(tc.rank_name)
        end.map do |tc|
          [:"#{tc.rank_name.downcase}_id", tc.id]
        end
      @query = @query.where(
        taxon_concepts_conditions.map { |c| "taxon_concept_#{c[0]} = #{c[1]}" }.join(' OR ')
      )
    end

    unless @reported_taxon_concepts_ids.empty?
      cascading_ranks = Rank.in_range(Rank::SPECIES, Rank::KINGDOM)
      reported_taxon_concepts = MTaxonConcept.where(id: @reported_taxon_concepts_ids)
      reported_taxon_concepts_conditions =
        reported_taxon_concepts.map do |tc|
          [:id, tc.id]
        end + reported_taxon_concepts.select do |tc|
          cascading_ranks.include?(tc.rank_name)
        end.map do |tc|
          [:"#{tc.rank_name.downcase}_id", tc.id]
        end
      @query = @query.where(
        reported_taxon_concepts_conditions.map { |c| "reported_taxon_concept_#{c[0]} = #{c[1]}" }.join(' OR ')
      )
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
      if !@internal && (w = Source.find_by_code('W')) && @sources_ids.include?(w.id)
        u = Source.find_by_code('U')
        @sources_ids << u.id if u
        @source_blank = true
      end
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
        @query = @query.where(["year >= ? AND year <= ?", @time_range_start, @time_range_end])
      end
    end

    initialize_internal_query if @internal
  end

  def initialize_internal_query
    if @report_type == :raw
      # includes would override the select clause
      @query = @query.preload(:reported_taxon_concept)
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
