class Checklist::Json::History < Checklist::History
  include Checklist::Json::Document
  include Checklist::Json::HistoryContent

  def initialize(options)
    super(options)
    @json_options = json_options
  end

end
