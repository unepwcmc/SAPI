class DocumentSearch
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt
  attr_reader :page, :per_page, :offset, :event_type, :event_id,
    :document_type, :document_title

  def initialize(options)
    initialize_params(options)
    initialize_query
  end

  def results
    results = @query.limit(@per_page).
      offset(@offset)
  end

  def total_cnt
    @query.count
  end

  def taxon_concepts
    @taxon_concepts ||= TaxonConcept.where(id: @taxon_concepts_ids)
  end

  def geo_entities
    @geo_entities ||= GeoEntity.where(id: @geo_entities_ids)
  end

  def document_tags
    @document_tags ||= DocumentTag.where(id: @document_tags_ids)
  end

  private

  def initialize_params(options)
    @options = DocumentSearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    @offset = @per_page * (@page - 1)
  end

  def initialize_query
    @query = Document.from('documents_view AS documents')
    add_conditions_for_event
    add_conditions_for_document
    add_extra_conditions
    add_ordering
  end

  def add_conditions_for_event
    return unless @event_id || @event_type
    @query = @query.joins('LEFT JOIN events ON events.id = documents.event_id')
    if @event_id.present?
      @query = @query.where(event_id: @event_id)
    elsif @event_type.present?
      @query = @query.where('events.type' => @event_type)
    end
  end

  def add_conditions_for_document
    @query = @query.search_by_title(@document_title) if @document_title.present?

    if @document_type.present?
      @query = @query.where('documents.type' => @document_type)
    end

    if !@document_date_start.blank?
      @query = @query.where("documents.date >= ?", @document_date_start)
    end
    if !@document_date_end.blank?
      @query = @query.where("documents.date <= ?", @document_date_end)
    end
  end

  def add_extra_conditions
    add_taxon_concepts_condition if @taxon_concepts_ids.present?
    add_geo_entities_condition if @geo_entities_ids.present?
    add_document_tags_condition if @document_tags_ids.present?
  end

  def add_taxon_concepts_condition
    @query = @query.where("taxon_concept_ids && ARRAY[#{@taxon_concepts_ids.join(',')}]")
  end

  def add_geo_entities_condition
    @query = @query.where("geo_entity_ids && ARRAY[#{@geo_entities_ids.join(',')}]")
  end

  def add_document_tags_condition
    @query = @query.where("document_tags_ids && ARRAY[#{@document_tags_ids.join(',')}]")
  end

  def add_ordering
    return if @document_title.present?

    @query = if @event_id.present?
      @query.order([:date, :title])
    else
      @query.order('documents.created_at DESC')
    end
  end

end
