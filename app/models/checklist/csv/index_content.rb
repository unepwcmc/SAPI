module Checklist::Csv::IndexContent
  COLUMNS = [:id, :full_name, :rank_name, :family_name, :class_name,
    :cites_accepted, :current_listing,
    :specific_annotation_symbol, :generic_annotation_symbol,
    :english_names_ary, :spanish_names_ary, :french_names_ary]

  def content(csv)
    csv << COLUMNS
    fetcher = Checklist::IndexFetcher.new(@animalia_rel)
    kingdom(csv, fetcher)
    fetcher = Checklist::IndexFetcher.new(@plantae_rel)
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