class CitesTrade::HomeController < CitesTradeController
  def index
    max_year = Trade::Shipment.maximum('year') || Date.today.year

    respond_to do |format|
      format.html do
        @years = (1975..max_year).to_a.reverse
        @default_year = Date.today.year - 2

        set_db_download_config
      end
    end
  end

  def download
    set_db_download_config
  end

  def view_results
    set_db_download_config
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
