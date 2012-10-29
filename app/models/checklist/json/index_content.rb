module Checklist::Json::IndexContent

  def content(json_file)
    fetcher = Checklist::IndexFetcher.new(@taxon_concepts_rel)
    # use Jsonify to build json in batches
    json = Jsonify::Builder.new(:format => :pretty)
    begin
      kingdom = fetcher.next
      kingdom.each{ |tc| json << tc.as_json(json_options) }
    end while not kingdom.empty?
    # Evaluate the result to a string
    json_file << json.compile!
  end

end