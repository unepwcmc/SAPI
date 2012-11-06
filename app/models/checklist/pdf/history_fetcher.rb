class Checklist::Pdf::HistoryFetcher < Checklist::HistoryFetcher
  def initialize(relation)
    super(relation)
    @last_seen_id = nil
  end
  def next
    results = super
    injector = Checklist::HigherTaxaInjector.new(results, @last_seen_id, true)
    res = injector.run
    @last_seen_id = injector.last_seen_id
    res
  end
end