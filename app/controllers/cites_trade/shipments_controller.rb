class CitesTrade::ShipmentsController < CitesTradeController
  respond_to :json

  def index
    @search = Trade::ShipmentsExportFactory.new(search_params)
    render :json => @search,
      :serializer => serializer_for_search(@search),
      :meta => metadata_for_search(@search)
  end

  private

  def serializer_for_search(search)
    if search.report_type == :comptab
      Trade::ShipmentComptabExportSerializer
    else
      Trade::ShipmentGrossNetExportSerializer
    end
  end

end
