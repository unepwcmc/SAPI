class CitesTrade::HomeController < CitesTradeController
  def index
    respond_to do |format|
      format.html do
        @years = (1975..Trade::Shipment.maximum('year')).to_a.reverse
      end
    end
  end

  def download
  end

  def view_results
  end

  def download_db
    full_download_path = Rails.application.credentials.dig(:cites_trade_full_download)
    send_file(
      "#{Rails.root.join("#{full_download_path}")}",
      filename: full_download_path.split('/').last,
      type: 'application/zip'
    )

    AnalyticsEvent.create(event_name: 'full_database_download', event_type: 'download')
  end
end
