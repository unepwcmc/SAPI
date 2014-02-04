# == Schema Information
#
# Table name: year_annual_reports_by_countries
#
#  no            :integer
#  name_en       :string(255)
#  year          :integer
#  reporter_type :text
#  year_created  :float
#

class YearAnnualReportsByCountry < ActiveRecord::Base
  attr_accessible :no, :name_en, :year, :reporter_type, :year_created

end
