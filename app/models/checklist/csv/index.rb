class Checklist::Csv::Index < Checklist::Index
  include Checklist::Csv::Document
  include Checklist::Csv::IndexContent

  def initialize(options={})
    super(options)
    @tmp_csv    = [Rails.root, "/tmp/", SecureRandom.hex(8), '.csv'].join
  end

end
