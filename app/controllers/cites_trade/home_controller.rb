class CitesTrade::HomeController < CitesTradeController

  def index
    @years = (1975..Trade::Shipment.maximum('year')).to_a.reverse
  end

  def download
  end

  def view_results
  end

end