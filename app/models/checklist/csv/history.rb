class Checklist::Csv::History < Checklist::History
  include Checklist::Csv::Document
  include Checklist::Csv::HistoryContent

  def initialize(options={})
    super(options)
    @tmp_csv    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.csv'].join
  end

end
