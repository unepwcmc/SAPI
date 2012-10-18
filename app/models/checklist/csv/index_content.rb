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
        entry = columns.map do |c|
          val = tc.send(c)
          val = val.map{ |s| "\"#{s}\"" }.join(', ') if val.is_a? Array
          val
        end
        csv << entry
      end
    end while not kingdom.empty?
  end

end