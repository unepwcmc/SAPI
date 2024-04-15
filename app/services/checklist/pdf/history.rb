class Checklist::Pdf::History < Checklist::History
  include Checklist::Pdf::Document
  include Checklist::Pdf::Helpers
  include Checklist::Pdf::HistoryContent

  def initialize(options = {})
    super(options)
    @input_name = 'history'
  end

end
