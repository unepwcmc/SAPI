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
        entry = columns.map{ |c| tc.send(c) }
        csv << entry
      end
    end while not kingdom.empty?
  end

end