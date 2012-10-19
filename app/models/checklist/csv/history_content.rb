module Checklist::Csv::HistoryContent

  def content(csv)
    csv << column_headers
    fetcher = Checklist::HistoryFetcher.new(@animalia_rel)
    kingdom(csv, fetcher)
    fetcher = Checklist::HistoryFetcher.new(@plantae_rel)
    kingdom(csv, fetcher)
  end

  def kingdom(csv, fetcher)
    begin
      kingdom = fetcher.next
      kingdom.each do |tc|
        csv << column_values(tc)
      end
    end while not kingdom.empty?
  end

end