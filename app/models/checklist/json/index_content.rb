module Checklist::Json::IndexContent

  def content(json)
    fetcher = Checklist::IndexFetcher.new(@animalia_rel)
    kingdom(json, fetcher)
    fetcher = Checklist::IndexFetcher.new(@plantae_rel)
    kingdom(json, fetcher)
  end

  def kingdom(json, fetcher)
    puts self.json_options.inspect
    begin
      kingdom = fetcher.next
      kingdom.each { |tc| json << tc.to_json(self.json_options); json << ",\n"}
    end while not kingdom.empty?
  end

end