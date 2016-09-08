class CitesTrade::HomeController < CitesTradeController

  def index
    respond_to do |format|
      format.html { @years = (1975..Trade::Shipment.maximum('year')).to_a.reverse }
    end
  end

  def download
  end

  def view_results
  end

end
