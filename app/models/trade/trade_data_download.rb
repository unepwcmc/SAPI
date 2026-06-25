# == Schema Information
#
# Table name: trade_trade_data_downloads
#
#  id             :integer          not null, primary key
#  appendix       :string(255)
#  city           :string
#  country        :string
#  exporter       :text
#  importer       :text
#  number_of_rows :integer
#  organization   :string
#  origin         :text
#  purpose        :text
#  report_type    :string(255)
#  source         :text
#  taxon          :string(255)
#  term           :text
#  unit           :text
#  user_ip        :string(255)
#  year_from      :integer
#  year_to        :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Trade::TradeDataDownload < ApplicationRecord
  # Used by app/models/trade/trade_data_download_logger.rb

  after_commit :async_downloads_cache_cleanup, on: [ :create, :update ]

private

  def async_downloads_cache_cleanup
    DownloadsCacheCleanupWorker.perform_async('trade_download_stats')
  end
end
