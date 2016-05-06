class DocumentSearch
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt
  attr_reader :page, :per_page, :offset, :event_type, :event_ids,
    :document_type, :title_query

  def initialize(options, interface)
    @interface = interface
    initialize_params(options)
    initialize_query
  end

  def results
    @query.limit(@per_page).offset(@offset)
  end

  def total_cnt
    if admin_interface?
      @query.count
    else
      query = "SELECT count(*) AS count_all FROM (#{@query.to_sql}) x"
      count = ActiveRecord::Base.connection.execute(query).first.try(:[], "count_all").to_i
    end
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

  def admin_interface?
    @interface == 'admin'
  end

  def table_name
    'api_documents_mview'
  end

  def initialize_params(options)
    @options = DocumentSearchParams.sanitize(options)
    @options[:show_private] = true if admin_interface?
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    @offset = @per_page * (@page - 1)
  end

  def initialize_query
    @query = Document.from("#{table_name} documents")
    @query = @query.where(is_public: true) if !admin_interface? && !@show_private
    add_conditions_for_event
    add_conditions_for_document
    add_extra_conditions
    if admin_interface?
      add_ordering_for_admin
    else
      add_ordering_for_public
      select_and_group_query
    end
  end

  def add_conditions_for_event
    if @event_ids.present?
      @query = @query.where(event_id: @event_ids)
      return
    end
    return unless @event_type.present?
    if @event_type == 'Other'
      # public interface event type "other"
      @query = @query.where(
        <<-SQL
          event_type IS NULL
          OR event_type NOT IN ('EcSrg', 'CitesCop', 'CitesAc', 'CitesPc', 'CitesTc', 'CitesExtraordinaryMeeting')
        SQL
      )
    else
      @query = @query.where('event_type IN (?)', @event_type.split(','))
    end
  end

  def add_conditions_for_document
    @query = @query.search_by_title(@title_query) if @title_query.present?

    if @document_type.present?
      @query = @query.where('document_type' => @document_type)
    end

    if admin_interface?
      if !@document_date_start.blank?
        @query = @query.where("documents.date >= ?", @document_date_start)
      end
      if !@document_date_end.blank?
        @query = @query.where("documents.date <= ?", @document_date_end)
      end
    end
  end

  def add_extra_conditions
    add_taxon_concepts_condition if @taxon_concepts_ids.present?
    add_geo_entities_condition if @geo_entities_ids.present?
    add_document_tags_condition if @document_tags_ids.present?
  end

  def add_taxon_concepts_condition
    @query = @query.where(
      "taxon_concept_ids && ARRAY[#{@taxon_concepts_ids.join(',')}]"
    )
  end

  def add_geo_entities_condition
    @query = @query.where("geo_entity_ids && ARRAY[#{@geo_entities_ids.join(',')}]")
  end

  def add_document_tags_condition
    @query = @query.where("document_tags_ids && ARRAY[#{@document_tags_ids.join(',')}]")
  end

  def add_ordering_for_admin
    return if @title_query.present?

    @query = if @event_ids.present?
      @query.order([:date_raw, :title])
    else
      @query.order('created_at DESC')
    end
  end

  def add_ordering_for_public
    @query = @query.order("date_raw DESC")
  end

  def select_and_group_query
    columns = "event_name, event_type, date, date_raw, is_public, document_type,
      proposal_number, primary_document_id,
      geo_entity_names, taxon_names,
      proposal_outcome, review_phase"
    aggregators = <<-SQL
      ARRAY_TO_JSON(
        ARRAY_AGG_NOTNULL(
          ROW(
            documents.id,
            documents.title,
            documents.language
          )::document_language_version
        )
      ) AS document_language_versions
    SQL
    @query = Document.from(
      '(' + @query.to_sql + ') documents'
    ).select(columns + "," + aggregators).group(columns)
    @query = @query.order('date_raw DESC, MAX(sort_index), MAX(title)')
  end

  def self.refresh
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW api_documents_mview')
  end

end
