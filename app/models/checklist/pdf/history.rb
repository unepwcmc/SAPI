#Encoding: utf-8
class Checklist::Pdf::History < Checklist::History
  include Checklist::Pdf::Document
  include Checklist::Pdf::HistoryContent

  def initialize(options={})
    super(options)
    @input_name = 'history'
    @footnote_title_string = "History of CITES listings – <page>"
  end

end
