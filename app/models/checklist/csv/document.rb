require 'csv'
module Checklist::Csv::Document

  def ext
    'csv'
  end

  def document
    @tmp_csv    = [Rails.root, "/tmp/", SecureRandom.hex(8), ".#{ext}"].join
    CSV.open(@tmp_csv, "wb") do |csv|
      yield csv
    end

    @download_path = @tmp_csv
  end

end