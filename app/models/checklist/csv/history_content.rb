module Checklist::Csv::HistoryContent
  COLUMNS = [:taxon_concept_id, :change_type_name, :species_listing_name, :effective_at, :party_name]

  def content(csv)
    csv << COLUMNS
    fetcher = Checklist::HistoryFetcher.new(@animalia_rel)
    kingdom(csv, fetcher)
    fetcher = Checklist::HistoryFetcher.new(@plantae_rel)
    kingdom(csv, fetcher)
  end

  def kingdom(csv, fetcher)
    begin
      kingdom = fetcher.next
      kingdom.each do |tc|
        entry = COLUMNS.map{ |c| tc.send(c) }
        csv << entry
      end
    end while not kingdom.empty?
  end

end