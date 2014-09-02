class DocumentSearch
  include CacheIterator
  include DocumentsSearchCache
  attr_reader :page, :per_page

  def initialize(params)
    @options = params
    #TODO
    @per_page = params['per_page'] || 50
    @page = params['page'] || 1

    initialize_query params
  end

  def results
    @query.limit(@per_page).
      offset(@per_page * (@page - 1)).all
  end

  def total_cnt
    @query.count
  end

  def document_types
    Document.select(:type).map(&:type).uniq
  end

  private

  def initialize_query(params)

    @query = Document
    if !params['event-id-search'].nil? && params['event-id-search'] != ""
      @query = @query.where("event_id = ?", params['event-id-search'])
    end
    if !params['document-title'].nil? && params['document-title'] != ""
      @query = @query.where("title = ?", params['document-title'])
    end
    if !params['document-type'].nil? && params['document-type'] != ""
      @query = @query.where("documents.type = ?", params['document-type'])
    end
    @query
  end

end