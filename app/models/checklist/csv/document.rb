require 'csv'
module Checklist::Csv::Document

  def document
    CSV.open(@tmp_csv, "wb") do |csv|
      yield csv
    end

    @download_path = @tmp_csv
  end

end