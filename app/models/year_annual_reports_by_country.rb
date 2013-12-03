class YearAnualReportsByCountry < ActiveRecord::Base
  attr_accessible :no,
                  :name_en,
                  :year,
                  :type
end