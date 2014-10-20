class Trade::ExportsController < TradeController
  respond_to :json

  def download
    search = Trade::ShipmentsExportFactory.new(search_params)
    respond_to do |format|
      format.html {
        result = search.export
        if result.is_a?(Array)
          send_file Pathname.new(result[0]).realpath, result[1]
        else
          redirect_to trade_root_url
        end
      }
      format.json {
        render :json => { :total => search.total_cnt }
      }
    end
  end

  def download_stats
    stats = Trade::TradeDataDownloadsExport.new()
    respond_to do |format|
      format.html {
        result = stats.export
        send_file Pathname.new(result[0]).realpath, result[1]
      }
    end
  end
end
