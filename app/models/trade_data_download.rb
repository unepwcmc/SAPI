# == Schema Information
#
# Table name: trade_data_downloads
#
# t.string   "user_ip"
# t.string   "report_type"
# t.integer  "year_from"
# t.integer  "year_to"
# t.string   "taxon"
# t.string   "appendix"
# t.string   "importer"
# t.string   "exporter"
# t.string   "origin"
# t.string   "term"
# t.string   "unit"
# t.string   "source"
# t.string   "purpose"
# t.datetime "created_at",  :null => false
# t.datetime "updated_at",  :null => false

class TradeDataDownload < ActiveRecord::Base

  attr_accessible :user_ip, :report_type, :year_from, :year_to, :taxon,
   :appendix, :importer, :exporter, :origin, :term, :unit, :source, :purpose

end
