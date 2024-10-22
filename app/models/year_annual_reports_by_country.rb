# == Schema Information
#
# Table name: year_annual_reports_by_countries
#
#  name_en       :string(255)
#  no            :bigint
#  reporter_type :text
#  year          :integer
#  year_created  :float
#

class YearAnnualReportsByCountry < ApplicationRecord
  # No idea where using this.
  # attr_accessible :no, :name_en, :year, :reporter_type, :year_created
end
