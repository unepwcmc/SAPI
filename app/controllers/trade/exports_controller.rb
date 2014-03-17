class Trade::ExportsController < TradeController
  respond_to :json

  def download
    search = Trade::ShipmentsExportFactory.new(search_params)
    respond_to do |format|
      format.html {
        result = search.export
        send_file Pathname.new(result[0]).realpath, result[1]
      }
      format.json {
        render :json => { :total => search.total_cnt }
      }
    end
  end

  def download_stats
    stats = Trade::TradeDataDownloadLogger.export
    respond_to do |format|
      format.html {
        send_file Pathname.new(stats).realpath, :type => 'text/csv'
      }
    end
  end
end
