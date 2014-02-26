class CitesTrade::ExportsController < CitesTradeController
  respond_to :json

  def download
    search = Trade::ShipmentsExportFactory.new(search_params)
    respond_to do |format|
      format.html {
        result = search.export
        send_file Pathname.new(result[0]).realpath, result[1]
        Trade::TradeDataDownloadLogger.log_download request, params, search.total_cnt
      }
      format.json {
        render :json => { :total => search.total_cnt }
      }
    end
  end

end
