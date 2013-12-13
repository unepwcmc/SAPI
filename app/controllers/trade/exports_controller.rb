class Trade::ExportsController < ApplicationController
  respond_to :json

  def download
    search = Trade::ShipmentsExportFactory.new(params[:filters])

    respond_to do |format|
      format.html {
        result = search.export
        if result.is_a?(Array)
          send_file result[0], result[1]
        else
          head :no_content
        end
      }
      format.json {
        render :json => { :total => search.total_cnt }
      }
    end
  end

end