class CitesTrade::ExportsController < CitesTradeController
  respond_to :json

  def download
    respond_to do |format|
      format.html {
        search = Trade::ShipmentsExportFactory.new(search_params.merge({
          :per_page => Trade::ShipmentsExport::PUBLIC_CSV_LIMIT
        }))
        result = search.export
        send_file Pathname.new(result[0]).realpath, result[1]
        Trade::TradeDataDownloadLogger.log_download request, params, search.total_cnt
      }
      format.json {
        search = Trade::ShipmentsExportFactory.new(search_params)
        render :json => {
          :total => search.total_cnt,
          :csv_limit => Trade::ShipmentsExport::PUBLIC_CSV_LIMIT,
          :web_limit => Trade::ShipmentsExport::PUBLIC_WEB_LIMIT
        }
      }
    end
  end

end
