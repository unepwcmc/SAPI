# == Schema Information
#
# Table name: trade_trade_data_downloads
#
#  id             :integer          not null, primary key
#  user_ip        :string(255)
#  report_type    :string(255)
#  year_from      :integer
#  year_to        :integer
#  taxon          :string(255)
#  appendix       :string(255)
#  importer       :string(255)
#  exporter       :string(255)
#  origin         :string(255)
#  term           :string(255)
#  unit           :string(255)
#  source         :string(255)
#  purpose        :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  number_of_rows :integer
#  city           :string
#  country        :string
#  organization   :string
#

class Trade::TradeDataDownload < ActiveRecord::Base

  attr_accessible :user_ip, :report_type, :year_from, :year_to, :taxon,
   :appendix, :importer, :exporter, :origin, :term, :unit, :source, :purpose,
   :number_of_rows, :city, :country, :organization

end
