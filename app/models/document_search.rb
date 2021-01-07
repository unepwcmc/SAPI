class DocumentSearch
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt
  attr_reader :page, :per_page, :offset, :event_type, :events_ids,
    :document_type, :title_query

  def initialize(options, interface)
    @interface = interface
    initialize_params(options)
    initialize_query
  end

  #TODO temporarly removing pagination here because of the new cascading feature. Add it back after the refactor of the SQL mviews  
  def results
    @query #.limit(@per_page).offset(@offset)
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
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
    @offset = @per_page * (@page - 1)
  end

  def initialize_query
    @query = Document.from("#{table_name} documents")
    @query = @query.where(is_public: true) unless @show_private
    add_conditions_for_event
    add_conditions_for_document
    add_extra_conditions
    if admin_interface?
      add_ordering_for_admin
    else
      select_and_group_query
    end
  end

  def add_conditions_for_event
    if @events_ids.present?
      @query = @query.where(event_id: @events_ids)
      return
    end
    return unless @event_type.present?
    if @event_type == 'Other'
      # public interface event type "other"
      @query = @query.where(
        <<-SQL
          event_type IS NULL
          OR event_type NOT IN ('EcSrg', 'CitesCop', 'CitesAc', 'CitesPc', 'CitesTc', 'CitesExtraordinaryMeeting', 'IdMaterials')
        SQL
      )
    else
      @query = @query.where('event_type IN (?)', @event_type.split(','))
    end
  end

  def add_conditions_for_document
    @query = @query.search_by_title(@title_query) if @title_query.present?

    if @document_type.present?
      @query = @query.where('document_type IN (?)', @document_type.split(','))
    end

    if @volume.present?
      @query = @query.where('volume IN (?)', @volume)
    end

    if admin_interface?
      if !@document_date_start.blank?
        @query = @query.where("documents.date_raw >= ?", @document_date_start)
      end
      if !@document_date_end.blank?
        @query = @query.where("documents.date_raw <= ?", @document_date_end)
      end
    end

    if @general_subtype.present?
      @query = @query.where('general_subtype IN (?)', @general_subtype.split(',').flatten)
    end
  end

  def add_extra_conditions
    if @taxon_concepts_ids.present? && @geo_entities_ids.present?
      add_citations_condition
    elsif @taxon_concepts_ids.present?
      add_taxon_concepts_condition
    elsif @geo_entities_ids.present?
      add_geo_entities_condition
    end
    add_document_tags_condition if @document_tags_ids.present?
  end

  def add_citations_condition
    combinations = @taxon_concepts_ids.product(@geo_entities_ids)
    condition_values = []
    condition_string = combinations.map do |c|
      condition_values += c
      'taxon_concept_id = ? AND geo_entity_id = ?'
    end.join(' OR ')
    filter_by_citations(
      condition_string,
      condition_values
    )
  end

  def add_taxon_concepts_condition
    filter_by_citations(
      'taxon_concept_id IN (?)',
      [@taxon_concepts_ids]
    )
  end

  def add_geo_entities_condition
    filter_by_citations(
      'geo_entity_id IN (?)',
      [@geo_entities_ids]
    )
  end

  def filter_by_citations(condition_string, condition_values)
    join_sql = ActiveRecord::Base.send(
      :sanitize_sql_array,
      [
        "JOIN (
        SELECT DISTINCT document_id
        FROM document_citations_mview
        WHERE #{condition_string}
        ) t ON t.document_id = documents.id",
        *condition_values
      ]
    )
    @query = @query.joins(join_sql)
  end

  def add_document_tags_condition
    @query = @query.where("document_tags_ids && ARRAY[#{@document_tags_ids.join(',')}]")
  end

  def add_ordering_for_admin
    return if @title_query.present?

    @query =
      if @events_ids.present?
        @query.order(['date_raw DESC', :title])
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
      geo_entity_names, taxon_names, taxon_concept_ids,
      proposal_outcome, review_phase"
    aggregators = <<-SQL
      ARRAY_TO_JSON(
        ARRAY_AGG_NOTNULL(
          ROW(
            documents.id,
            documents.title,
            documents.language,
            #{locale_document}
          )::document_language_version
        )
      ) AS document_language_versions
    SQL
    @query = Document.from(
      '(' + @query.to_sql + ') documents'
    ).select(columns + "," + aggregators).group(columns)
  end

  def locale_document
    return 'TRUE' unless @language.present?
    <<-SQL
      CASE
      WHEN documents.language = '#{@language.upcase}' AND '#{@language}' = 'en'
      THEN 'true'
      WHEN documents.language != '#{@language.upcase}' AND '#{@language}' = 'en'
      THEN 'false'
      WHEN '#{@language}' != 'en' THEN
        CASE
        WHEN documents.language = '#{@language.upcase}'
        THEN 'true'
        WHEN documents.language = 'EN'
        THEN 'default'
        ELSE 'false'
        END
      END
    SQL
  end

  REFRESH_INTERVAL = 5

  def self.documents_need_refreshing?
    Document.where('updated_at > ?', REFRESH_INTERVAL.minutes.ago).limit(1).count > 0 ||
    Document.count < Document.from('api_documents_mview documents').count
  end

  def self.citations_need_refreshing?
    DocumentCitation.where('updated_at > ?', REFRESH_INTERVAL.minutes.ago).limit(1).count > 0 ||
    DocumentCitation.count < DocumentCitation.select('DISTINCT id').
      from('document_citations_mview citations').count
  end

  def self.refresh_documents
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW api_documents_mview')
    DocumentSearch.increment_cache_iterator
  end

  def self.refresh_citations_and_documents
    ActiveRecord::Base.connection.execute('REFRESH MATERIALIZED VIEW document_citations_mview')
    refresh_documents
  end

  def self.clear_cache
    RefreshDocumentsWorker.perform_async
    DownloadsCacheCleanupWorker.perform_async(:documents)
  end

end
