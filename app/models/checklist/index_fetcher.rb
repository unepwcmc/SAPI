class Checklist::IndexFetcher
  def initialize(relation)
    @relation = relation
    @limit = 5000
    @offset = 0
  end

  def next
    results = @relation.limit(@limit).offset(@offset)
    @offset += @limit
    results
  end
end
