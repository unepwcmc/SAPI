class Checklist::Json::History < Checklist::History
  include Checklist::Json::Document
  include Checklist::Json::HistoryContent
end
