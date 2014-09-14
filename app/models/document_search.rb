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
      offset(@offset).uniq_by(&:id)
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

  private

  def initialize_params(options)
    @options = DocumentSearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    @offset = @per_page * (@page - 1)
  end

  def initialize_query
    @query = Document.joins('LEFT JOIN events ON events.id = documents.event_id')

    add_conditions_for_event
    add_conditions_for_document
    add_extra_conditions
    add_ordering
  end

  def add_conditions_for_event
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
    return unless [@taxon_concepts_ids, @geo_entities_ids].any?(&:present?)

    @query = @query.joins("""
      LEFT JOIN document_citations
      ON document_citations.document_id = documents.id
    """.squish)

    add_taxon_concepts_condition if @taxon_concepts_ids.present?
    add_geo_entities_condition if @geo_entities_ids.present?
  end

  def add_taxon_concepts_condition
    @query = @query.joins("""
      LEFT JOIN document_citation_taxon_concepts
      ON document_citation_taxon_concepts.document_citation_id = document_citations.id
    """.squish)
    @query = @query.where(
      'document_citation_taxon_concepts.taxon_concept_id' => @taxon_concepts_ids
    )
  end

  def add_geo_entities_condition
    geo_entity_type_ids = GeoEntityType.where(
      :name => [GeoEntityType::COUNTRY, GeoEntityType::TERRITORY]
    ).pluck(:id)

    @query = @query.joins("""
      LEFT JOIN document_citation_geo_entities
      ON document_citation_geo_entities.document_citation_id = document_citations.id
      LEFT JOIN geo_entities
      ON document_citation_geo_entities.geo_entity_id = geo_entities.id
    """)

    @query = @query.where(
      'geo_entities.id' => @geo_entities_ids,
      'geo_entities.geo_entity_type_id' => geo_entity_type_ids
    )
  end

  def add_ordering
    return if @document_title.present?

    @query = if @event_id.present?
      @query.order([:date, :title])
    else
      @query.order('created_at DESC')
    end
  end

end
