module Checklist::Csv::IndexContent

  def content(csv)
    csv << column_headers
    fetcher = Checklist::IndexFetcher.new(@animalia_rel)
    kingdom(csv, fetcher)
    fetcher = Checklist::IndexFetcher.new(@plantae_rel)
    kingdom(csv, fetcher)
  end

  def kingdom(csv, fetcher)
    begin
      kingdom = fetcher.next
      kingdom.each do |tc|
        values = taxon_concepts_csv_columns.map do |c|
          tc.send(c)
        end
        entry = values.map do |val|
          val = val.join(', ') if val.is_a? Array
          val
        end
        csv << entry
      end
    end while !kingdom.empty?
  end

end
