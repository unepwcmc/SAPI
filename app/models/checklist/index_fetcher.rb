class Checklist::IndexFetcher
  def initialize(query)
    puts "initialize with:"
    puts query.inspect
    @query = query
    @limit = 5000
    @offset = 0
  end
  def next
    results = MTaxonConcept.find_by_sql(
      @query.to_sql(@limit, @offset)
    )
    @offset += @limit
    results
  end
end