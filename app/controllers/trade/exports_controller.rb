class Trade::ExportsController < ApplicationController
  respond_to :json

  def download
    result = Trade::ShipmentsExportFactory.new(params[:filters]).export

    respond_to do |format|
      format.html {
        if result.is_a?(Array)
          send_file result[0], result[1]
        else
          head :no_content
        end
      }
      format.json {
        render :json => {:total => result.is_a?(Array) ? 1 : 0}
      }
    end
  end

end