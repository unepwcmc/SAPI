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
#  importer       :text
#  exporter       :text
#  origin         :text
#  term           :text
#  unit           :text
#  source         :text
#  purpose        :text
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
