module Checklist::Json::IndexContent

  def content(json)
    json << '['
    fetcher = Checklist::IndexFetcher.new(@animalia_rel)
    kingdom(json, fetcher)
    fetcher = Checklist::IndexFetcher.new(@plantae_rel)
    kingdom(json, fetcher)
    json << ']'
  end

  def kingdom(json, fetcher)
    begin
      kingdom = fetcher.next
      kingdom.each { |tc| json << tc.to_json(@json_options); json << ",\n"}
    end while not kingdom.empty?
  end

end