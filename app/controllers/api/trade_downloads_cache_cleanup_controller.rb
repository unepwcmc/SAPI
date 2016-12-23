class Api::TradeDownloadsCacheCleanupController < ApplicationController
  respond_to :json

  def index
    message = ''
    begin
      DownloadsCacheCleanupWorker.perform_async(:shipments)
    rescue
      message = 'Something went wrong'
    end
    message = 'Shipments downloads successfully cleared' unless message.present?
    render json: {
      message: message
    }
  end
end
