class Trade::ExportsController < ApplicationController
  respond_to :json

  def download
    
    search = Trade::ShipmentsExportFactory.new(params[:filters])

    respond_to do |format|
      
      format.html {
        result = search.export
        if result.is_a?(Array)
          send_file result[0], result[1]
          rows = search.total_cnt
          Trade::TradeDataDownloadLogger.log_download request, params, rows
        else
          head :no_content
        end
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
        send_file stats, :type => 'text/csv'
      }
    end
  end
end