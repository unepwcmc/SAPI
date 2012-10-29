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
        tc.m_listing_changes.each do |lc|
          csv << taxon_concepts_csv_columns.map { |c| tc.send(c) } +
          listing_changes_csv_columns.map { |c| lc.send(c) }
        end
      end
    end while not kingdom.empty?
  end

end