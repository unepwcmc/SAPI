class Checklist::Pdf::HistoryFetcher < Checklist::HistoryFetcher
  def next
    results = super
    injector = Checklist::HigherTaxaInjector.new(results)
    injector.run
  end
end