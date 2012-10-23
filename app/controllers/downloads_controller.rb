class DownloadsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  # GET downloads/
  #
  # Lists a set of downloads for a given list of IDs
  # TODO: if there is a current version of the download requested,
  # ignore the requested downloaded and return the cached current
  # version
  def index
    ids = params[:ids] || ""
    @downloads = Download.find(ids.split(","))

    render :json => @downloads
  end

  # POST downloads/
  def create
    @download = Download.create(params[:download])

    DownloadWorker.perform_async(@download, @checklist_params)

    render :json => {downloads: [@download]}
  end

  # GET downloads/:id/
  def show
    @download = Download.find(params[:id])

    render :json => {status: @download.status}
  end

  # GET downloads/:id/download
  def download
    @download = Download.find(params[:id])

    if @download.status == Download::COMPLETED
      # send file!
    else
      render :json => {error: "Download not processed"}
    end
  end

  private

  def not_found
    render :json => {error: "No downloads available"}
  end
end
