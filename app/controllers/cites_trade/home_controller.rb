class CitesTrade::HomeController < CitesTradeController

  def index
    respond_to do |format|
      format.html {
        @years = (1975..Trade::Shipment.maximum('year')).to_a.reverse
        @full_download_link = Rails.application.secrets['cites_trade_full_download']
      }
    end
  end

  def download
  end

  def view_results
  end

end
