class DocumentSearch
  include CacheIterator
  include SearchCache # this provides #cached_results and #cached_total_cnt
  attr_reader :page, :per_page

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
    @options = DocumentSearchParams.sanitize(options)
    @options.keys.each { |k| instance_variable_set("@#{k}", @options[k]) }
  end

  def initialize_query
    @query = Document.joins(:event)
    if !@event_id.blank?
      @query = @query.where(event_id: @event_id)
    elsif !@event_type.blank?
      @query = @query.where('events.type' => @event_type)
    end
    if !@document_title.blank?
      @query = @query.search_by_title(@document_title)
    else
      @query = @query.order([:date, :title])
    end
    if !@document_type.blank?
      @query = @query.where('documents.type' => @document_type)
    end
  end

end