class Checklist::HistoryFetcher
  def initialize(relation)
    @relation = relation
    @limit = 1000
    @offset = 0
  end
  def next
    results = @relation.limit(@limit).offset(@offset)
    @offset += @limit
    injector = Checklist::HigherTaxaInjector.new(results)
    injector.run
  end
end