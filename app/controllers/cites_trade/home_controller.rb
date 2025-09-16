class CitesTrade::HomeController < CitesTradeController
  def db_download_config
    @@db_download_config ||= Rails.application.config_for(:cites_trade_db_download)
  end

  def index
    max_year = Trade::Shipment.maximum('year') || Date.today.year

    respond_to do |format|
      format.html do
        @years = (1975..max_year).to_a.reverse

        @db_download_version = db_download_config[:version]
        @db_download_size = db_download_config[:size]
      end
    end
  end

  def download
  end

  def view_results
  end

  def download_db
    download_path = db_download_config[:file_path]
    full_download_path = "#{Rails.root.join("#{download_path}")}"

    send_file(
      full_download_path,
      filename: download_path.split('/').last,
      type: 'application/zip'
    )

    AnalyticsEvent.create(event_name: 'full_database_download', event_type: 'download')
  end
end
