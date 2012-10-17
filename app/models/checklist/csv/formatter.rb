require 'csv'
module Checklist::Csv::Formatter

  def generate_csv
    CSV.open(@tmp_csv, "wb") do |csv|
      yield csv
    end

    @download_path = @tmp_csv
  end

end