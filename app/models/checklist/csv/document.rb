require 'csv'
module Checklist::Csv::Document

  def document
    CSV.open(@download_path, "wb") do |csv|
      yield csv
    end

    @download_path
  end

end
