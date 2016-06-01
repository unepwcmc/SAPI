class Trade::ExportsController < TradeController
  respond_to :json

  def download
    search = Trade::ShipmentsExportFactory.new(search_params)
    respond_to do |format|
      format.html {
        result = search.export
        if result.is_a?(Array)
          # this was added in order to prevent download managers from
          # failing when chunked_transfer_encoding is set in nginx (1.8.1)
          file_path = Pathname.new(result[0]).realpath
          response.headers['Content-Length'] = File.size(file_path).to_s
          send_file file_path, result[1]
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
    stats = Trade::TradeDataDownloadsExport.new
    respond_to do |format|
      format.html {
        result = stats.export
        # this was added in order to prevent download managers from
        # failing when chunked_transfer_encoding is set in nginx (1.8.1)
        file_path = Pathname.new(result[0]).realpath
        response.headers['Content-Length'] = File.size(file_path).to_s
        send_file file_path, result[1]
      }
    end
  end
end
