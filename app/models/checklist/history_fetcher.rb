class Checklist::HistoryFetcher
  def initialize(relation)
    @relation = relation
    @limit = 100
    @offset = 0
  end
  def next
    results = @relation.limit(@limit).offset(@offset)
    @offset += @limit
    results
  end
end